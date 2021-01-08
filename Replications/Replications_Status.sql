--File: Replications/Replications_Status.sql
--Extracted from https://basitaalishan.com/2012/07/25/transact-sql-script-to-monitor-replication-status/
--Compilled in https://github.com/beumof/SQL-Server-Admin-scripts
--Added in 2021-01-08

USE [distribution]
 
IF OBJECT_ID('Tempdb.dbo.#ReplStats') IS NOT NULL
    DROP TABLE #ReplStats
 
CREATE TABLE [dbo].[#ReplStats] (
    [DistributionAgentName] [nvarchar](100) NOT NULL
    ,[DistributionAgentStartTime] [datetime] NOT NULL
    ,[DistributionAgentRunningDurationInSeconds] [int] NOT NULL
    ,[IsAgentRunning] [bit] NULL
    ,[ReplicationStatus] [varchar](14) NULL
    ,[LastSynchronized] [datetime] NOT NULL
    ,[Comments] [nvarchar](max) NOT NULL
    ,[Publisher] [sysname] NOT NULL
    ,[PublicationName] [sysname] NOT NULL
    ,[PublisherDB] [sysname] NOT NULL
    ,[Subscriber] [nvarchar](128) NULL
    ,[SubscriberDB] [sysname] NULL
    ,[SubscriptionType] [varchar](64) NULL
    ,[DistributionDB] [sysname] NULL
    ,[Article] [sysname] NOT NULL
    ,[UndelivCmdsInDistDB] [int] NULL
    ,[DelivCmdsInDistDB] [int] NULL
    ,[CurrentSessionDeliveryRate] [float] NOT NULL
    ,[CurrentSessionDeliveryLatency] [int] NOT NULL
    ,[TotalTransactionsDeliveredInCurrentSession] [int] NOT NULL
    ,[TotalCommandsDeliveredInCurrentSession] [int] NOT NULL
    ,[AverageCommandsDeliveredInCurrentSession] [int] NOT NULL
    ,[DeliveryRate] [float] NOT NULL
    ,[DeliveryLatency] [int] NOT NULL
    ,[TotalCommandsDeliveredSinceSubscriptionSetup] [int] NOT NULL
    ,[SequenceNumber] [varbinary](16) NULL
    ,[LastDistributerSync] [datetime] NULL
    ,[Retention] [int] NULL
    ,[WorstLatency] [int] NULL
    ,[BestLatency] [int] NULL
    ,[AverageLatency] [int] NULL
    ,[CurrentLatency] [int] NULL
    ) ON [PRIMARY]
 
INSERT INTO #ReplStats
SELECT da.[name] AS [DistributionAgentName]
    ,dh.[start_time] AS [DistributionAgentStartTime]
    ,dh.[duration] AS [DistributionAgentRunningDurationInSeconds]
    ,md.[isagentrunningnow] AS [IsAgentRunning]
    ,CASE md.[status]
        WHEN 1
            THEN '1 - Started'
        WHEN 2
            THEN '2 - Succeeded'
        WHEN 3
            THEN '3 - InProgress'
        WHEN 4
            THEN '4 - Idle'
        WHEN 5
            THEN '5 - Retrying'
        WHEN 6
            THEN '6 - Failed'
        END AS [ReplicationStatus]
    ,dh.[time] AS [LastSynchronized]
    ,dh.[comments] AS [Comments]
    ,md.[publisher] AS [Publisher]
    ,da.[publication] AS [PublicationName]
    ,da.[publisher_db] AS [PublisherDB]
    ,CASE
        WHEN da.[anonymous_subid] IS NOT NULL
            THEN UPPER(da.[subscriber_name])
        ELSE UPPER(s.[name])
        END AS [Subscriber]
    ,da.[subscriber_db] AS [SubscriberDB]
    ,CASE da.[subscription_type]
        WHEN '0'
            THEN 'Push'
        WHEN '1'
            THEN 'Pull'
        WHEN '2'
            THEN 'Anonymous'
        ELSE CAST(da.[subscription_type] AS [varchar](64))
        END AS [SubscriptionType]
    ,md.[distdb] AS [DistributionDB]
    ,ma.[article] AS [Article]
    ,ds.[UndelivCmdsInDistDB]
    ,ds.[DelivCmdsInDistDB]
    ,dh.[current_delivery_rate] AS [CurrentSessionDeliveryRate]
    ,dh.[current_delivery_latency] AS [CurrentSessionDeliveryLatency]
    ,dh.[delivered_transactions] AS [TotalTransactionsDeliveredInCurrentSession]
    ,dh.[delivered_commands] AS [TotalCommandsDeliveredInCurrentSession]
    ,dh.[average_commands] AS [AverageCommandsDeliveredInCurrentSession]
    ,dh.[delivery_rate] AS [DeliveryRate]
    ,dh.[delivery_latency] AS [DeliveryLatency]
    ,dh.[total_delivered_commands] AS [TotalCommandsDeliveredSinceSubscriptionSetup]
    ,dh.[xact_seqno] AS [SequenceNumber]
    ,md.[last_distsync] AS [LastDistributerSync]
    ,md.[retention] AS [Retention]
    ,md.[worst_latency] AS [WorstLatency]
    ,md.[best_latency] AS [BestLatency]
    ,md.[avg_latency] AS [AverageLatency]
    ,md.[cur_latency] AS [CurrentLatency]
FROM [distribution]..[MSdistribution_status] ds
INNER JOIN [distribution]..[MSdistribution_agents] da ON da.[id] = ds.[agent_id]
INNER JOIN [distribution]..[MSArticles] ma ON ma.publisher_id = da.publisher_id
    AND ma.[article_id] = ds.[article_id]
INNER JOIN [distribution]..[MSreplication_monitordata] md ON [md].[job_id] = da.[job_id]
INNER JOIN [distribution]..[MSdistribution_history] dh ON [dh].[agent_id] = md.[agent_id]
    AND md.[agent_type] = 3
INNER JOIN [master].[sys].[servers] s ON s.[server_id] = da.[subscriber_id]
--Created WHEN your publication has the immediate_sync property set to true. This property dictates 
--whether snapshot is available all the time for new subscriptions to be initialized. 
--This affects the cleanup behavior of transactional replication. If this property is set to true, 
--the transactions will be retained for max retention period instead of it getting cleaned up
--as soon as all the subscriptions got the change. 
WHERE da.[subscriber_db] <> 'virtual'
    AND da.[anonymous_subid] IS NULL
    AND dh.[start_time] = (
        SELECT TOP 1 start_time
        FROM [distribution]..[MSdistribution_history] a
        INNER JOIN [distribution]..[MSdistribution_agents] b ON a.[agent_id] = b.[id]
            AND b.[subscriber_db] <> 'virtual'
        WHERE [runstatus] <> 1
        ORDER BY [start_time] DESC
        )
    AND dh.[runstatus] <> 1
 
SELECT 'Transactional Replication Summary' AS [Comments];
 
SELECT [DistributionAgentName]
    ,[DistributionAgentStartTime]
    ,[DistributionAgentRunningDurationInSeconds]
    ,[IsAgentRunning]
    ,[ReplicationStatus]
    ,[LastSynchronized]
    ,[Comments]
    ,[Publisher]
    ,[PublicationName]
    ,[PublisherDB]
    ,[Subscriber]
    ,[SubscriberDB]
    ,[SubscriptionType]
    ,[DistributionDB]
    ,SUM([UndelivCmdsInDistDB]) AS [UndelivCmdsInDistDB]
    ,SUM([DelivCmdsInDistDB]) AS [DelivCmdsInDistDB]
    ,[CurrentSessionDeliveryRate]
    ,[CurrentSessionDeliveryLatency]
    ,[TotalTransactionsDeliveredInCurrentSession]
    ,[TotalCommandsDeliveredInCurrentSession]
    ,[AverageCommandsDeliveredInCurrentSession]
    ,[DeliveryRate]
    ,[DeliveryLatency]
    ,[TotalCommandsDeliveredSinceSubscriptionSetup]
    ,[SequenceNumber]
    ,[LastDistributerSync]
    ,[Retention]
    ,[WorstLatency]
    ,[BestLatency]
    ,[AverageLatency]
    ,[CurrentLatency]
FROM #ReplStats
GROUP BY [DistributionAgentName]
    ,[DistributionAgentStartTime]
    ,[DistributionAgentRunningDurationInSeconds]
    ,[IsAgentRunning]
    ,[ReplicationStatus]
    ,[LastSynchronized]
    ,[Comments]
    ,[Publisher]
    ,[PublicationName]
    ,[PublisherDB]
    ,[Subscriber]
    ,[SubscriberDB]
    ,[SubscriptionType]
    ,[DistributionDB]
    ,[CurrentSessionDeliveryRate]
    ,[CurrentSessionDeliveryLatency]
    ,[TotalTransactionsDeliveredInCurrentSession]
    ,[TotalCommandsDeliveredInCurrentSession]
    ,[AverageCommandsDeliveredInCurrentSession]
    ,[DeliveryRate]
    ,[DeliveryLatency]
    ,[TotalCommandsDeliveredSinceSubscriptionSetup]
    ,[SequenceNumber]
    ,[LastDistributerSync]
    ,[Retention]
    ,[WorstLatency]
    ,[BestLatency]
    ,[AverageLatency]
    ,[CurrentLatency]
 
SELECT 'Transactional Replication Summary Details' AS [Comments];
 
SELECT [Publisher]
    ,[PublicationName]
    ,[PublisherDB]
    ,[Article]
    ,[Subscriber]
    ,[SubscriberDB]
    ,[SubscriptionType]
    ,[DistributionDB]
    ,SUM([UndelivCmdsInDistDB]) AS [UndelivCmdsInDistDB]
    ,SUM([DelivCmdsInDistDB]) AS [DelivCmdsInDistDB]
FROM #ReplStats
GROUP BY [Publisher]
    ,[PublicationName]
    ,[PublisherDB]
    ,[Article]
    ,[Subscriber]
    ,[SubscriberDB]
    ,[SubscriptionType]
    ,[DistributionDB]