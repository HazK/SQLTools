RunDateTime] = dbo.agent_datetime(HIST.run_date,HIST.run_time)



SELECT        
[JobName]     = JOB.name,
       [StepName]    = HIST.step_name,
              [RunDateTime] = dbo.agent_datetime(HIST.run_date,HIST.run_time)
FROM          sysjobs JOB
INNER JOIN    sysjobhistory HIST ON HIST.job_id = JOB.job_id
ORDER BY      HIST.run_date, HIST.run_time