@isTest
private class GardenTriggerHandlerTest {

    @isTest
    static void createOneNewGarden() {
        CAMPX__Garden__c newGarden = new CAMPX__Garden__c(Name = 'New Garden');
        insert newGarden;
        CAMPX__Garden__c insertedGarden = [  SELECT   CAMPX__Status__c,
                                                        CAMPX__Max_Plant_Count__c,
                                                        CAMPX__Minimum_Plant_Count__c,
                                                        CAMPX__Total_Plant_Count__c,
                                                        CAMPX__Total_Unhealthy_Plant_Count__c
                                                FROM    CAMPX__Garden__c
                                                LIMIT 1
                                            ];
        Assert.areEqual('Awaiting Resources' , insertedGarden.CAMPX__Status__c);
        Assert.areEqual(100, insertedGarden.CAMPX__Max_Plant_Count__c);
        Assert.areEqual(1, insertedGarden.CAMPX__Minimum_Plant_Count__c);
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Plant_Count__c);
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Unhealthy_Plant_Count__c);
    }

    @isTest
    static void createOneNewGardenWithExistingData() {
        CAMPX__Garden__c newGarden = new CAMPX__Garden__c(Name = 'New Garden', CAMPX__Max_Plant_Count__c = 50);
        insert newGarden;
        CAMPX__Garden__c insertedGarden = [  SELECT     CAMPX__Status__c,
                                                        CAMPX__Max_Plant_Count__c,
                                                        CAMPX__Minimum_Plant_Count__c,
                                                        CAMPX__Total_Plant_Count__c,
                                                        CAMPX__Total_Unhealthy_Plant_Count__c
                                                FROM    CAMPX__Garden__c
                                                LIMIT 1
                                            ];
        Assert.areEqual('Awaiting Resources' , insertedGarden.CAMPX__Status__c);
        Assert.areEqual(50, insertedGarden.CAMPX__Max_Plant_Count__c);
        Assert.areEqual(1, insertedGarden.CAMPX__Minimum_Plant_Count__c);
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Plant_Count__c);
        Assert.areEqual(0, insertedGarden.CAMPX__Total_Unhealthy_Plant_Count__c);
    }

    @isTest
    private static void CreateNewTaskUponGardenCreation() {
        List<User> listOfManagers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c newGardenWhithManager = new CAMPX__Garden__c(Name = 'New Garden', CAMPX__Manager__c = listOfManagers.get(0).id);
        insert newGardenWhithManager;
        List <Task> taskId = [SELECT id, subject FROM Task WHERE OwnerId = :listOfManagers.get(0).Id];
        Assert.areEqual(1, taskId.size());
        Assert.areEqual('Acquire Plants', taskId.get(0).Subject);

    }

    @istest
    private static void createTaskUponGardenUpdateAddManager() {
        List<User> listOfManagers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c newGardenWhithoutManager = new CAMPX__Garden__c(Name = 'New Garden');
        insert newGardenWhithoutManager;
        Assert.areEqual(null, newGardenWhithoutManager.CAMPX__Manager__c);
        newGardenWhithoutManager.CAMPX__Manager__c = listOfManagers.get(0).id;
        update newGardenWhithoutManager;
        List <Task> taskId = [SELECT id, subject FROM Task WHERE OwnerId = :listOfManagers.get(0).Id];
        Assert.areEqual(1, taskId.size());
        Assert.areEqual('Acquire Plants', taskId.get(0).Subject);
    }

    @istest
    private static void createTaskUponGardenUpdateChangeManager() {
        List<User> listOfManagers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c newGardenWhithExistingManager = new CAMPX__Garden__c(Name = 'New Garden', CAMPX__Manager__c = listOfManagers.get(0).id);
        insert newGardenWhithExistingManager;
        Assert.areEqual(listOfManagers.get(0).id, newGardenWhithExistingManager.CAMPX__Manager__c);
        newGardenWhithExistingManager.CAMPX__Manager__c = listOfManagers.get(1).id;
        update newGardenWhithExistingManager;
        List <Task> taskId = [SELECT id, subject FROM Task];
        Assert.areEqual(1, taskId.size());
        Assert.areEqual('Acquire Plants', taskId.get(0).Subject);
    }
    
    @istest
    private static void transferOpenTasksToNewGardener() {
        List<User> managers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c gardenOne = new CAMPX__Garden__c(Name = 'Garden One', CAMPX__Manager__c = managers.get(0).id);
        insert gardenOne;
        List <Task> tasksOfManagerZero = [SELECT id, subject, ownerId FROM Task WHERE OwnerId = :managers.get(0).Id];
        Assert.areEqual(1, tasksOfManagerZero.size(), 'Manager Zero should have 1 task');
        gardenOne.CAMPX__Manager__c = managers.get(7).Id;
        update gardenOne;
        List <Task> tasksOfManagerSeven = [SELECT id, subject, ownerId FROM Task  WHERE OwnerId = :managers.get(7).Id];
        Assert.areEqual( 1, tasksOfManagerSeven.size(),'Manager Seven should have 1 task');
        tasksOfManagerZero = [SELECT id, subject, ownerId FROM Task WHERE OwnerId = :managers.get(0).Id];
        Assert.areEqual(0, tasksOfManagerZero.size(),'Manager Zero should have 0 task');
    }

    @istest
    private static void deleteUncompletedTasksWithoutManager() {
        List<User> managers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c gardenOne = new CAMPX__Garden__c(Name = 'Garden One', CAMPX__Manager__c = managers.get(0).id);
        insert gardenOne;
        List <Task> tasksOfManagerZero = [SELECT id, subject, ownerId FROM Task WHERE OwnerId = :managers.get(0).Id];
        Assert.areEqual(1, tasksOfManagerZero.size(), 'Manager Zero should have 1 task');
        gardenOne.CAMPX__Manager__c = null;
        update gardenOne;
        List <Task> allTasks = [SELECT id, subject, ownerId FROM Task];
        Assert.areEqual(0, allTasks.size(), 'There should be no existing tasks');
    }

    @istest
    private static void fillManagerStartDate() {
        List<User> managers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c gardenOne = new CAMPX__Garden__c(Name = 'Garden One', CAMPX__Manager__c = managers.get(0).id);
        insert gardenOne;
        Date today = System.today();
        CAMPX__Garden__c createdGarden = [SELECT id, CAMPX__Manager_Start_Date__c FROM CAMPX__Garden__c WHERE name = 'Garden One'];
        Assert.areEqual(today, createdGarden.CAMPX__Manager_Start_Date__c, 'Manager Start Date should be today');        
    }

    @istest
    private static void clearManagerStartDate() {
        List<User> managers = [SELECT id, name, firstName, lastName, userName FROM User];
        CAMPX__Garden__c gardenOne = new CAMPX__Garden__c(Name = 'Garden One', CAMPX__Manager__c = managers.get(0).id);
        insert gardenOne;
        Date today = System.today();
        CAMPX__Garden__c createdGarden = [SELECT id, CAMPX__Manager_Start_Date__c FROM CAMPX__Garden__c WHERE name = 'Garden One'];
        Assert.areEqual(today, createdGarden.CAMPX__Manager_Start_Date__c, 'Manager Start Date should be today');
        gardenOne.CAMPX__Manager__c = null;
        update gardenOne;
        createdGarden  = [SELECT id, CAMPX__Manager_Start_Date__c FROM CAMPX__Garden__c WHERE name = 'Garden One'];
        Assert.areEqual(null, gardenOne.CAMPX__Manager_Start_Date__c, 'Manager Start Date should be null');
    }

    @istest
    private static void calcultateGardenCapacityAtInsert() {
        CAMPX__Garden__c randomGarden = new CAMPX__Garden__c (Name = 'Random Garden', CAMPX__Total_Plant_Count__c = 50, CAMPX__Max_Plant_Count__c = 100);
        test.startTest();
        insert randomGarden;
        test.stopTest();
        CAMPX__Garden__c insertedGarden = [SELECT CAMPX__Capacity__c FROM CAMPX__Garden__c WHERE Name = 'Random Garden'];
        Assert.areEqual(50, insertedGarden.CAMPX__Capacity__c, 'Capacity should be equal to 50');
    }
    @istest
    private static void calcultateZeroGardenCapacityAtInsert() {
        CAMPX__Garden__c randomGarden = new CAMPX__Garden__c (Name = 'Random Garden', CAMPX__Total_Plant_Count__c = 0, CAMPX__Max_Plant_Count__c = 100);
        test.startTest();
        insert randomGarden;
        test.stopTest();
        CAMPX__Garden__c insertedGarden = [SELECT CAMPX__Capacity__c FROM CAMPX__Garden__c WHERE Name = 'Random Garden'];
        Assert.areEqual(0, insertedGarden.CAMPX__Capacity__c, 'Capacity should be equal to 0');
    }
    @istest
    private static void calcultateGardenCapacityAtUpdate() {
        CAMPX__Garden__c randomGarden = new CAMPX__Garden__c (Name = 'Random Garden', CAMPX__Total_Plant_Count__c = 50, CAMPX__Max_Plant_Count__c = 100);
        test.startTest();
        insert randomGarden;
        randomGarden.CAMPX__Total_Plant_Count__c = 60;
        update randomGarden;
        test.stopTest();
        CAMPX__Garden__c insertedGarden = [SELECT CAMPX__Capacity__c FROM CAMPX__Garden__c WHERE Name = 'Random Garden'];
        Assert.areEqual(60, insertedGarden.CAMPX__Capacity__c, 'Capacity should be equal to 60');
    }
    @istest
    private static void calcultateNullGardenCapacityAtUpdate() {
        CAMPX__Garden__c randomGarden = new CAMPX__Garden__c (Name = 'Random Garden', CAMPX__Total_Plant_Count__c = 50, CAMPX__Max_Plant_Count__c = 100);
        test.startTest();
        insert randomGarden;
        randomGarden.CAMPX__Total_Plant_Count__c = null;
        update randomGarden;
        test.stopTest();
        System.debug('Total plant count before update : '+ randomGarden.CAMPX__Total_Plant_Count__c);
        CAMPX__Garden__c insertedGarden = [SELECT CAMPX__Capacity__c FROM CAMPX__Garden__c WHERE Name = 'Random Garden'];
        Assert.areEqual(0, insertedGarden.CAMPX__Capacity__c, 'Capacity should be equal to 0');
    }

}