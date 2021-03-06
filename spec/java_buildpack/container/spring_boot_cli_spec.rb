# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/container/spring_boot_cli'

module JavaBuildpack::Container

  describe SpringBootCli do
    include_context 'component_helper'

    it 'should not detect a non-Groovy project',
       app_fixture: 'container_main' do

      expect(component.detect).to be_nil
    end

    it 'should not detect a .groovy directory',
       app_fixture: 'dot_groovy' do

      expect(component.detect).to be_nil
    end

    it 'should not detect if the application has a WEB-INF directory',
       app_fixture: 'container_spring_boot_cli_groovy_with_web_inf' do

      expect(component.detect).to be_nil
    end

    it 'should not detect if one of the Groovy files is not a POGO',
       app_fixture: 'container_spring_boot_cli_non_pogo' do

      expect(component.detect).to be_nil
    end

    it 'should not detect if one of the Groovy files has a main() method',
       app_fixture: 'container_spring_boot_cli_main_method' do

      expect(component.detect).to be_nil
    end

    it 'should detect if there are Groovy files and they are all POGOs with no main method and there is no WEB-INF directory',
       app_fixture: 'container_spring_boot_cli_valid_app' do

      expect(component.detect).to eq("spring-boot-cli=#{version}")
    end

    it 'should extract Spring Boot CLI from a ZIP',
       app_fixture: 'container_spring_boot_cli_valid_app',
       cache_fixture: 'stub-spring-boot-cli.tar.gz' do

      component.compile

      expect(app_dir + '.spring-boot-cli/bin/spring').to exist
    end

    it 'should link classpath JARs',
       app_fixture: 'container_spring_boot_cli_valid_app',
       cache_fixture: 'stub-spring-boot-cli.tar.gz' do

      component.compile

      lib = app_dir + '.spring-boot-cli/lib'

      jar_1 = lib + 'test-jar-1.jar'
      expect(jar_1).to exist
      expect(jar_1).to be_symlink

      jar_2 = lib + 'test-jar-2.jar'
      expect(jar_2).to exist
      expect(jar_2).to be_symlink

      expect(lib + 'test-text.txt').not_to exist
    end

    it 'should return command',
       app_fixture: 'container_spring_boot_cli_valid_app' do

      expect(component.release).to eq("JAVA_HOME=#{java_home} JAVA_OPTS=#{java_opts_str} " +
                                          '.spring-boot-cli/bin/spring run --local directory/pogo_4.groovy ' +
                                          'pogo_1.groovy pogo_2.groovy pogo_3.groovy -- --server.port=$PORT')
    end

    def java_opts_str
      "\"#{java_opts.sort.join(' ')}\""
    end

  end

end
