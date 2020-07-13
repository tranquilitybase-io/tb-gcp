      pipelineJob('Create Jobs Pipeline') {
        quietPeriod(0)
        concurrentBuild(false)
        logRotator {
          numToKeep(10)
        }
        triggers {
          cron("H/15 * * * *")
        }
        definition {
          cps {
            script('createJobs()')
          }
        }
      }