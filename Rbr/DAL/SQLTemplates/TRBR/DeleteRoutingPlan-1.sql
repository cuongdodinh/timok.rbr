-- temp
UPDATE [RbrDb_267].[dbo].[RoutingPlan]
   SET [name] = 'Default'
       WHERE [routing_plan_id] = 1
--temp


DELETE FROM [RbrDb_267].[dbo].[TerminationChoice]
	where [RbrDb_267].[dbo].[TerminationChoice].[routing_plan_id] in (
										SELECT [RbrDb_267].[dbo].[RoutingPlan].[routing_plan_id] FROM [RbrDb_267].[dbo].[RoutingPlan]
										where name like 'zz%'
										)

DELETE FROM [RbrDb_267].[dbo].[RoutingPlanDetail]
 where [RbrDb_267].[dbo].[RoutingPlanDetail].[routing_plan_id] in (
										SELECT [RbrDb_267].[dbo].[RoutingPlan].[routing_plan_id] FROM [RbrDb_267].[dbo].[RoutingPlan]
										where name like 'zz%'
									)
UPDATE [RbrDb_267].[dbo].[Service]
   SET [default_routing_plan_id] = 1
   WHERE [default_routing_plan_id] in (
										SELECT [RbrDb_267].[dbo].[RoutingPlan].[routing_plan_id] FROM [RbrDb_267].[dbo].[RoutingPlan]
										where name like 'zz%'
									   )

select * FROM [RbrDb_267].[dbo].[RoutingPlan]
 where [RbrDb_267].[dbo].[RoutingPlan].[routing_plan_id] in (
										SELECT [RbrDb_267].[dbo].[RoutingPlan].[routing_plan_id] FROM [RbrDb_267].[dbo].[RoutingPlan]
										where name like 'zz%'
									)