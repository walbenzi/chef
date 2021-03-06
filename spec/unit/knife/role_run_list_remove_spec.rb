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

describe Chef::Knife::RoleRunListRemove do
  before(:each) do
    Chef::Config[:role_name]  = "will"
    @setup = Chef::Knife::RoleRunListAdd.new
    @setup.name_args = [ "will", "role[monkey]", "role[person]" ]

    @knife = Chef::Knife::RoleRunListRemove.new
    @knife.config = {
      :print_after => nil
    }
    @knife.name_args = [ "will", "role[monkey]" ]
    @knife.stub(:output).and_return(true)

    @role = Chef::Role.new()
    @role.name("will")
    @role.stub(:save).and_return(true)

    @knife.ui.stub(:confirm).and_return(true)
    Chef::Role.stub(:load).and_return(@role)

  end



  describe "run" do


#    it "should display all the things" do
#      @knife.run
#      @role.to_json.should == 'show all the things'
#    end

    it "should load the node" do
      Chef::Role.should_receive(:load).with("will").and_return(@role)
      @knife.run
    end

     it "should remove the item from the run list" do
       @setup.run
       @knife.run
       @role.run_list[0].should == 'role[person]'
       @role.run_list[1].should be_nil
     end

     it "should save the node" do
       @role.should_receive(:save).and_return(true)
       @knife.run
     end

     it "should print the run list" do
       @knife.should_receive(:output).and_return(true)
       @knife.config[:print_after] = true
       @setup.run
       @knife.run
     end

     describe "run with a list of roles and recipes" do
       it "should remove the items from the run list" do
         @setup.name_args = [ "will", "recipe[orange::chicken]", "role[monkey]", "recipe[duck::type]", "role[person]", "role[bird]", "role[town]" ]
         @setup.run
         @knife.name_args = [ 'will', 'role[monkey]' ]
         @knife.run
         @knife.name_args = [ 'will', 'recipe[duck::type]' ]
         @knife.run
         @role.run_list.should_not include('role[monkey]')
         @role.run_list.should_not include('recipe[duck::type]')
         @role.run_list[0].should == 'recipe[orange::chicken]'
         @role.run_list[1].should == 'role[person]'
         @role.run_list[2].should == 'role[bird]'
         @role.run_list[3].should == 'role[town]'
       end
     end
  end
end



