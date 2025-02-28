List<Low_Ink__e> events = new List<Low_Ink__e>();
for (Integer i = 0; i < 100; i++) {
    events.add(new Low_Ink__e(DeviceId__c = i, Status__c = 'Failed'));
}
EventBus.publish(events);
