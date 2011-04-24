require 'rubygems'
require 'ruote/part/local_participant'
require 'mcollective'

include MCollective::RPC

module Ruote
  class McParticipant
    include LocalParticipant
    include MCollective::RPC

    def initialize(opts)
    end

    def consume(workitem)

      wi = workitem.to_h

      require 'pp'
      pp wi

      options = {:verbose    => false,
                 :timeout    => 5,
                 :disctimeout=> 5,
                 :config     => "/etc/mcollective/client.cfg",
                 :filter     => MCollective::Util.empty_filter}

      client = rpcclient(workitem.fields['mc_agent'], {:options => options})
      client.progress = false

      # Make mc request
      nodes_responded = []
      args = workitem.fields['mc_args'] || {}
      client.send(workitem.fields['mc_action'], args) do |resp|
        begin
          nodes_responded << resp[:senderid]
        rescue Exception => e
          puts "Exception on mc call"
          exit
        end
      end

      # Set response
      workitem.set_field('mc_nodes', client.discover) 

      reply_to_engine(workitem)
    end

    def cancel(fei, flavour)
    end
  end
end