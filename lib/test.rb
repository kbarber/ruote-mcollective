require 'rubygems'
require 'ruote'
require 'ruote/engine'
require 'ruote/worker'
require 'ruote/storage/fs_storage'
require 'ruote/part/mcollective_participant'
require 'pp'

# preparing the engine

engine = Ruote::Engine.new(
  Ruote::Worker.new(
    Ruote::FsStorage.new('ruote_work')))

# registering participants
#

engine.register_participant :setup do |workitem|
  workitem.fields['mc_agent'] = "discovery"
  workitem.fields['mc_action'] = "ping"
end

engine.register_participant :mc_participant, Ruote::McParticipant

engine.register_participant :show_results do |workitem|
  pp workitem
  puts "Result: #{workitem.fields['mc_results']}"
end

pdef = Ruote.process_definition :name => 'test' do
  sequence do
    participant :setup
    participant :mc_participant
    participant :show_results
  end
end

# launching, creating a process instance

wfid = engine.launch(pdef)

engine.wait_for(wfid)
