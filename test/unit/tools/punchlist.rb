module Test
  module Quality
    module Tools
      # Test for the 'bigfiles' tool within the quality gem
      module Punchlist
        def punchlist_expected_args
          "--glob '{Rakefile,Dockerfile,{*,.*}.{md,rb,rake,gemspec,swift,cpp," \
          'c,java,py,clj,cljs,scala,js,yml,sh,json},{src,app,config,db,lib,' \
          'test,spec,feature}/**/{*,.*}.' \
          '{md,rb,rake,gemspec,swift,cpp,c,java,py,clj,cljs,' \
          "scala,js,yml,sh,json}}'"
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
