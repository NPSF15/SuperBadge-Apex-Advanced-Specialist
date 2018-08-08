trigger OrderTrigger on Order (after update)
{
	if (Trigger.isAfter)
	{
		OrderHelper.AfterUpdate(Trigger.New, Trigger.Old);
	}
}