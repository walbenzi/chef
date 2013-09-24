#
# Author:: Adam Jacob (<adam@opscode.com>)
# Author:: Will Albenzi (<walbenzi@gmail.com>)
# Copyright:: Copyright (c) 2008 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Chef::Knife::RoleEnvRunListAdd do
  before(:each) do
    Chef::Config[:role_name]  = "websimian"
    Chef::Config[:env_name]  = "QA"
    @knife = Chef::Knife::RoleEnvRunListAdd.new
    @knife.config = {
      :after => nil
    }
    @knife.name_args = [ "will", "QA", "role[monkey]" ]
    #@knife.name_args = [ "will", "QA", "role[monkey]", "role[acorns]" ]
    @knife.stub!(:output).and_return(true)
    @role = Chef::Role.new() 
    @role.stub!(:save).and_return(true)
    Chef::Role.stub!(:load).and_return(@role)
  end

  describe "run" do

#    it "should have a QA environment" do
#      @knife.run
#      @role.to_json.should == 'show all the things'
#    end

    it "should have a QA environment" do
      @knife.run
      @role.active_run_list_for('QA').should == 'QA'
    end

    it "should load the role named will" do
      Chef::Role.should_receive(:load).with("will")
      @knife.run
    end

    it "should be able to add an environment specific run list" do
      @knife.run
      @role.run_list_for('QA')[0].should == 'role[monkey]'
    end

    it "should save the role" do
      @role.should_receive(:save)
      @knife.run
    end


    it "should print the run list" do
      @knife.should_receive(:output).and_return(true)
      @knife.run
    end

     describe "with -a or --after specified" do
      it "should add to the run list after the specified entry" do
        @role.run_list_for("QA") << "role[acorns]"
        @role.run_list_for("QA") << "role[barn]"
        @knife.config[:after] = "role[acorns]"
        @knife.run
        @role.run_list_for("QA")[0].should == "role[acorns]"
        @role.run_list_for("QA")[1].should == "role[monkey]"
        @role.run_list_for("QA")[2].should == "role[barn]"
      end
    end

    describe "with more than one role or recipe" do
      it "should add to the run list all the entries" do
        @knife.name_args = [ "will", "QA", "role[monkey],role[duck]" ]
        @role.run_list_for("QA") << "role[acorns]"
        @knife.run
      #@role.to_json.should == 'show all the things'
        @role.run_list_for("QA")[0].should == "role[acorns]"
        @role.run_list_for("QA")[1].should == "role[monkey]"
        @role.run_list_for("QA")[2].should == "role[duck]"
      end
    end
#
#    describe "with more than one role or recipe with space between items" do
#      it "should add to the run list all the entries" do
#        @knife.name_args = [ "adam", "role[monkey], role[duck]" ]
#        @node.run_list << "role[acorns]"
#        @knife.run
#        @node.run_list[0].should == "role[acorns]"
#        @node.run_list[1].should == "role[monkey]"
#        @node.run_list[2].should == "role[duck]"
#      end
#    end
#
#    describe "with more than one role or recipe as different arguments" do
#      it "should add to the run list all the entries" do
#        @knife.name_args = [ "adam", "role[monkey]", "role[duck]" ]
#        @node.run_list << "role[acorns]"
#        @knife.run
#        @node.run_list[0].should == "role[acorns]"
#        @node.run_list[1].should == "role[monkey]"
#        @node.run_list[2].should == "role[duck]"
#      end
#    end
#
#    describe "with more than one role or recipe as different arguments and list separated by comas" do
#      it "should add to the run list all the entries" do
#        @knife.name_args = [ "adam", "role[monkey]", "role[duck],recipe[bird::fly]" ]
#        @node.run_list << "role[acorns]"
#        @knife.run
#        @node.run_list[0].should == "role[acorns]"
#        @node.run_list[1].should == "role[monkey]"
#        @node.run_list[2].should == "role[duck]"
#      end
#    end
#
#    describe "with one role or recipe but with an extraneous comma" do
#      it "should add to the run list one item" do
#        @knife.name_args = [ "adam", "role[monkey]," ]
#        @node.run_list << "role[acorns]"
#        @knife.run
#        @node.run_list[0].should == "role[acorns]"
#        @node.run_list[1].should == "role[monkey]"
#      end
#    end
  end
end
