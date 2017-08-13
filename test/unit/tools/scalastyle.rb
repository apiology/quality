# frozen_string_literal: true
module Test
  module Quality
    module Tools
      # Test for the 'scalastyle' tool within the quality gem
      module Scalastyle
        def scalastyle_expected_args
          " -c 'project/scalastyle_config.xml' "\
          " -x 'src/test/scala'"\
          " s1.scala s2.scala"
        end

        def expect_find_scalastyle_config
          @mocks[:config]
            .expects(:scalastyle_config)
            .returns('project/scalastyle_config.xml')
            .at_least(1)
        end

        def expect_find_scalastyle_exclude
          @mocks[:config]
            .expects(:scalastyle_exclude)
            .returns('src/test/scala')
            .at_least(1)
        end

        def scalastyle_quality_checker_args
          ['scalastyle',
           {
             args: scalastyle_expected_args,
             gives_error_code_on_no_relevant_code: true,
             gives_error_code_on_violations: true,
           },
           'metrics',
           false,
           0]
        end

        def expect_scalastyle_run_with_args(quality_checker)
          @mocks[:quality_checker_class]
            .expects(:new).with(*scalastyle_quality_checker_args)
            .returns(quality_checker)
        end

        def expect_scalastyle_run(quality_checker)
          expect_scalastyle_run_with_args(quality_checker)
          expect_find_scala_files
          expect_find_scalastyle_config
          expect_find_scalastyle_exclude
        end
      end
    end
  end
end
