module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Punchlist
        def punchlist_expected_args
          "--glob '{Dockerfile,Rakefile,{*,.*}.{c,clj,cljs,cpp,gemspec," \
          'java,js,json,md,py,rake,rb,scala,sh,swift,' \
          'yml},{app,config,db,feature,lib,' \
          'spec,src,test,www}/**/{*,.*}.' \
          '{c,clj,cljs,cpp,gemspec,' \
          "java,js,json,md,py,rake,rb,scala,sh,swift,yml}}' " \
          "--exclude-glob '{db/schema.rb}'"
        end

        def expect_punchlist_run(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with('punchlist',
                                { args: punchlist_expected_args },
                                'metrics',
                                false)
            .returns(quality_checker)
        end
      end
    end
  end
end
