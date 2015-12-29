module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module BigFiles
        def expected_source_files_glob
          "{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,json,py,rake,rb," \
          'scala,sh,swift,' \
          'yml},{app,config,db,feature,lib,spec,src,test,www' \
          '}' \
          '/**/{*,.*}.{c,clj,cljs,cpp,gemspec,html,java,js,json,py,rake,rb,' \
          'scala,sh,swift,' \
          "yml}}"
        end

        def bigfiles_expected_args
          "--glob '" + expected_source_files_glob + "' " \
          "--exclude-glob '{**/vendor/**,db/schema.rb}'"
        end

        def expect_bigfiles_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('bigfiles',
                                { args: bigfiles_expected_args },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
