module Nanite
  class Mapper
    class OfflineQueue
      def run(options = {})
        setup_offline_queue
      end

      def setup_offline_queue
        offline_queue = amq.queue(@offline_queue, :durable => true)
        offline_queue.subscribe(:ack => true) do |info, deliverable|
          deliverable = serializer.load(deliverable, :insecure)
          targets = cluster.targets_for(deliverable)
          unless targets.empty?
            Nanite::Log.debug("Recovering message from offline queue: #{deliverable.to_s([:from, :tags, :target])}")
            info.ack
            if deliverable.kind_of?(Request)
              if job = job_warden.jobs[deliverable.token]
                job.targets = targets
              else
                deliverable.reply_to = identity
                job_warden.new_job(deliverable, targets)
              end
            end
            cluster.route(deliverable, targets)
          end
        end

        EM.add_periodic_timer(options[:offline_redelivery_frequency]) { offline_queue.recover }
      end
    end
  end
end