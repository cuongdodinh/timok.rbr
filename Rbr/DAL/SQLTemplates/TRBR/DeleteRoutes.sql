--DELETE FROM [RbrDb_267].[dbo].[DialCode]
--      WHERE route_id in (239, 240, 241, 532, 533)

--DELETE FROM [RbrDb_267].[dbo].[CarrierAcctEPmap]
--      WHERE carrier_route_id in (
--								select carrier_route_id FROM [RbrDb_267].[dbo].[CarrierRoute]
--								WHERE route_id in (239, 240, 241, 532, 533)
--								)

--DELETE FROM [RbrDb_267].[dbo].[CarrierRateHistory]
--      WHERE carrier_route_id in (
--								select carrier_route_id FROM [RbrDb_267].[dbo].[CarrierRoute]
--								WHERE route_id in (239, 240, 241, 532, 533)
--								)

--DELETE FROM [RbrDb_267].[dbo].[TerminationChoice]
--      WHERE carrier_route_id in (
--								select carrier_route_id FROM [RbrDb_267].[dbo].[CarrierRoute]
--								WHERE route_id in (239, 240, 241, 532, 533)
--								)

--DELETE FROM [RbrDb_267].[dbo].[CarrierRoute]
--      WHERE route_id in (239, 240, 241, 532, 533)

--DELETE FROM [RbrDb_267].[dbo].[WholesaleRateHistory]
--      WHERE wholesale_route_id in (
--								select wholesale_route_id FROM [RbrDb_267].[dbo].[WholesaleRoute]
--								WHERE route_id in (239, 240, 241, 532, 533)
--								)


--DELETE FROM [RbrDb_267].[dbo].[WholesaleRoute]
--      WHERE route_id in (239, 240, 241, 532, 533)


--DELETE FROM [RbrDb_267].[dbo].[RoutingPlanDetail]
--      WHERE route_id in (239, 240, 241, 532, 533)

DELETE FROM [RbrDb_267].[dbo].[Route]
      WHERE route_id in (239, 240, 241, 532, 533)


