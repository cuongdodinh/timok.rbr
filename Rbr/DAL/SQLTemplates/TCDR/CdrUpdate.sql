UPDATE [CdrDb_269_200710].[dbo].[CDR]
   SET [prefix_in] = left([local_number], patindex('%#%' , [local_number])),
	   [local_number] = right([local_number], len([local_number]) - patindex('%#%' , [local_number]))
where local_number like '%#%' 
and prefix_in =''
and start between '2007-10-19 00:00:00' and '2007-10-19 23:59:59'

