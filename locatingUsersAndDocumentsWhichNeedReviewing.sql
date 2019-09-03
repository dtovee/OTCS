select userid.ValInt as userId , userid.count --, rdate.ValDate, dtc.DataID
-- collect all of the document ids which need to be reviewed
,
--substring(
(
	select --userId2.ValInt,
	cast(dtc2.DataID as varchar) + ',' as 'data()'
	--userId2.ValInt, dtc2.DataID, rdate2.ValDate
	--substring(',' + cast(dtc2.DataID as varchar),2,9999) + ',' as 'data()'
	from livelink.livelink.DTreeCore dtc2
	inner join livelink.livelink.LLAttrData cv2 on dtc2.dataid=cv2.id and dtc2.versionNum=cv2.vernum and cv2.ValStr='PUK SEMS' --and cv.VerNum=9
	-- catalog information
	left outer join livelink.livelink.LLAttrData rdate2  on dtc2.dataid=rdate2.id and dtc2.versionNum=rdate2.vernum and rdate2.AttrID=13
	left outer join livelink.livelink.LLAttrData userId2 on dtc2.dataid=userId2.id and dtc2.versionNum=userId2.vernum and userId2.AttrID=6
	left outer join livelink.livelink.LLAttrData DocNum2 on dtc2.dataid=DocNum2.id and dtc2.versionNum=DocNum2.vernum and DocNum2.AttrID=18
	-- getting user information
	inner join livelink.livelink.KUAF kuaf2 on userId2.ValInt=kuaf2.id
	where
	dtc2.Deleted = 0 and
	--userId2.ValInt=384828 and
	userId2.ValInt=userid.ValInt and
	rdate2.ValDate is not null and
	userId2.ValInt is not null and
	kuaf2.MailAddress is not null and
	DocNum2.ValStr is not null
	and (
		   GETDATE() between DATEADD(WEEK, -1, DATEADD(MONTH, -2, rdate2.ValDate)) and DATEADD(MONTH, -2, rdate2.ValDate)
		or GETDATE() between DATEADD(WEEK, -1, DATEADD(MONTH, -1, rdate2.ValDate)) and DATEADD(MONTH, -1, rdate2.ValDate)
		or GETDATE() between DATEADD(WEEK, -1, DATEADD(WEEK,  -2, rdate2.ValDate)) and DATEADD(WEEK,  -2, rdate2.ValDate)
		or datediff(day,GETDATE(),rdate2.ValDate) < 0
	)

	FOR XML PATH('')
)
--,0,999)
as objectIds
from
-- get the list of users who have documents to review
(
	select
	userId.ValInt as ValInt, count(*) as count
	--userId.ValInt,dtc.dataid,rdate.ValDate
	-- the main table to retrieve the object information
	from livelink.livelink.DTreeCore dtc
	-- linking to the correct version of the catalog
	inner join livelink.livelink.LLAttrData cv on dtc.dataid=cv.id and dtc.versionNum=cv.vernum and cv.ValStr='PUK SEMS' --and cv.VerNum=9
	-- catalog information
	left outer join livelink.livelink.LLAttrData rdate  on dtc.dataid=rdate.id  and dtc.versionNum=rdate.VerNum  and rdate.AttrID=13
	left outer join livelink.livelink.LLAttrData userId on dtc.dataid=userId.id and dtc.versionNum=userId.vernum and userId.AttrID=6
	left outer join livelink.livelink.LLAttrData DocNum on dtc.dataid=DocNum.id and dtc.versionNum=DocNum.vernum and DocNum.AttrID=18
	-- getting user information
	inner join livelink.livelink.KUAF kuaf on userId.ValInt=kuaf.id
	where dtc.Deleted = 0 and
	--userId.ValInt=384828 and
	rdate.ValDate is not null and
	userId.ValInt is not null and
	kuaf.MailAddress is not null and
	DocNum.ValStr is not null
	and (
	   GETDATE() between DATEADD(WEEK, -1, DATEADD(MONTH, -2, rdate.ValDate)) and DATEADD(MONTH, -2, rdate.ValDate)
	or GETDATE() between DATEADD(WEEK, -1, DATEADD(MONTH, -1, rdate.ValDate)) and DATEADD(MONTH, -1, rdate.ValDate)
	or GETDATE() between DATEADD(WEEK, -1, DATEADD(WEEK,  -2, rdate.ValDate)) and DATEADD(WEEK,  -2, rdate.ValDate)
	or datediff(day,GETDATE(),rdate.ValDate) < 0
	)
	group by userId.ValInt
	--order by 2 desc
) as userid
order by userid.count desc
