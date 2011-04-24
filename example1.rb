#!/usr/bin/env ruby

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

# This participant sets up the mc agent items
engine.register_participant :setup do |workitem|
  workitem.fields['mc_agent'] = "discovery"
  workitem.fields['mc_action'] = "ping"
end

# Register mc_participant
engine.register_participant :mc_participant, Ruote::McParticipant

# This participant just shows results
engine.register_participant :show_results do |workitem|
  puts "Result: #{workitem.fields['mc_discover'].join(" ")}"
end

# And here is our workflow 
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
