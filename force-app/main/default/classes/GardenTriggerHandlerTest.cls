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

    @istest
    private static void calculateGardenHealthIndex(){
        List<CAMPX__Plant__c> listOfPlants = new List<CAMPX__Plant__c>();
        CAMPX__Garden__c anyGarden = new CAMPX__Garden__c (Name = 'Any Garden', CAMPX__Max_Plant_Count__c = 100);
        test.startTest();
        insert anyGarden;
        CAMPX__Plant__c healthyPlant = new CAMPX__Plant__c(Name = 'Healthy Plant', CAMPX__Status__c = 'Healthy', CAMPX__Garden__c = anyGarden.id);
        listOfPlants.add(healthyPlant);
        CAMPX__Plant__c unHealthyPlant = new CAMPX__Plant__c(Name = 'Unhealthy Plant', CAMPX__Status__c = 'Sick', CAMPX__Garden__c = anyGarden.id);
        listOfPlants.add(unHealthyPlant);
        insert listOfPlants;
        test.stopTest();
        CAMPX__Garden__c insertedAnyGarden = [SELECT CAMPX__Total_Plant_Count__c, CAMPX__Total_Unhealthy_Plant_Count__c, CAMPX__Health_Index__c FROM CAMPX__Garden__c WHERE Name = 'Any Garden' LIMIT 1];
        System.debug('NBL*** Total Plant Count dans le jardin : ' + insertedAnyGarden.CAMPX__Total_Plant_Count__c);
        System.debug('NBL*** Total unhealty Plants dans le jardin : ' + insertedAnyGarden.CAMPX__Total_Unhealthy_Plant_Count__c);
        Assert.areEqual(50.00, insertedAnyGarden.CAMPX__Health_Index__c, 'Index should be 50.00');
    }

    @isTest
    static void testUpdateGardenStatus() {
        // Create gardens with different scenarios
        List<CAMPX__Garden__c> gardens = new List<CAMPX__Garden__c>{
            new CAMPX__Garden__c(Name='Closed', CAMPX__Status__c='Permanent Closure', CAMPX__Capacity__c=50),
            new CAMPX__Garden__c(Name='ZeroCap', CAMPX__Capacity__c=0),
            new CAMPX__Garden__c(Name='OverCap', CAMPX__Capacity__c=150),
            new CAMPX__Garden__c(Name='Operational', CAMPX__Capacity__c=80, CAMPX__Total_Plant_Count__c=100, CAMPX__Minimum_Plant_Count__c=50, CAMPX__Health_Index__c=80),
            new CAMPX__Garden__c(Name='Awaiting', CAMPX__Capacity__c=60, CAMPX__Total_Plant_Count__c=40, CAMPX__Minimum_Plant_Count__c=50, CAMPX__Health_Index__c=60),
            new CAMPX__Garden__c(Name='Awaiting Health Index', CAMPX__Capacity__c=75, CAMPX__Total_Plant_Count__c=40, CAMPX__Minimum_Plant_Count__c=50, CAMPX__Health_Index__c=60),
            new CAMPX__Garden__c(Name='Awaiting Total Plant', CAMPX__Capacity__c=75, CAMPX__Total_Plant_Count__c=40, CAMPX__Minimum_Plant_Count__c=50, CAMPX__Health_Index__c=75)
        };
        insert gardens;

        // Call the method
        Test.startTest();
        GardenTriggerHandler.updateGardenStatus(gardens);
        Test.stopTest();

        // Assert expected statuses
        System.assertEquals('Permanent Closure', gardens[0].CAMPX__Status__c, 'Should remain Permanent Closure');
        System.assertEquals('Temporary Closure', gardens[1].CAMPX__Status__c, 'Should be Temporary Closure');
        System.assertEquals('Over Capacity', gardens[2].CAMPX__Status__c, 'Should be Over Capacity');
        System.assertEquals('Operational', gardens[3].CAMPX__Status__c, 'Should be Operational');
        System.assertEquals('Awaiting Resources', gardens[4].CAMPX__Status__c, 'Should be Awaiting Resources');
        System.assertEquals('Awaiting Resources', gardens[5].CAMPX__Status__c, 'Should be Awaiting Health Index');
        System.assertEquals('Awaiting Resources', gardens[6].CAMPX__Status__c, 'Should be Awaiting Total Plant');
    }
    @isTest
    private static void testAvoidNegativeValuesInsert() {
        // Test data
        List<CAMPX__Garden__c> gardens = new List<CAMPX__Garden__c>{
            new CAMPX__Garden__c(
                Name = 'Negative Min Count',
                CAMPX__Minimum_Plant_Count__c = -1
            ),
            new CAMPX__Garden__c(
                Name = 'Negative Max Count',
                CAMPX__Max_Plant_Count__c = -5
            ),
            new CAMPX__Garden__c(
                Name = 'Negative Total Count',
                CAMPX__Total_Plant_Count__c = -10
            ),
            new CAMPX__Garden__c(
                Name = 'Negative Unhealthy Count',
                CAMPX__Total_Unhealthy_Plant_Count__c = -3
            )
        };
        
        // Test insert with negative values
        Test.startTest();
        try {
            insert gardens;
            System.assert(false, 'Should have thrown an exception');
        } catch (DmlException e) {
            // Verify error message
            System.assert(e.getMessage().contains('CAMPX__Plant_Count__c fields must be greater than or equal to zero'), 
                'Expected error message for negative plant count values');
        }
        Test.stopTest();
    }

@isTest
private static void testAvoidNegativeValuesUpdate() {
    // Create garden with valid values
    CAMPX__Garden__c garden = new CAMPX__Garden__c(
        Name = 'Test Garden',
        CAMPX__Minimum_Plant_Count__c = 1,
        CAMPX__Max_Plant_Count__c = 100,
        CAMPX__Total_Plant_Count__c = 0,
        CAMPX__Total_Unhealthy_Plant_Count__c = 0
    );
    insert garden;
    
    // Test different negative value scenarios
    Map<String, Decimal> fieldTests = new Map<String, Decimal>{
        'CAMPX__Minimum_Plant_Count__c' => -1,
        'CAMPX__Max_Plant_Count__c' => -5,
        'CAMPX__Total_Plant_Count__c' => -10,
        'CAMPX__Total_Unhealthy_Plant_Count__c' => -3
    };

    Test.startTest();
    for(String fieldName : fieldTests.keySet()) {
        try {
            // Reset garden to valid values
            garden = [SELECT Id, Name, CAMPX__Minimum_Plant_Count__c, CAMPX__Max_Plant_Count__c, 
                     CAMPX__Total_Plant_Count__c, CAMPX__Total_Unhealthy_Plant_Count__c 
                     FROM CAMPX__Garden__c WHERE Id = :garden.Id];
            
            // Set negative value for current field
            garden.put(fieldName, fieldTests.get(fieldName));
            update garden;
            
            Assert.fail('Expected exception for negative value in ' + fieldName + ' was not thrown');
        } catch (DmlException e) {
            // Verify error message
            Assert.isTrue(
                e.getMessage().contains('Plant Count fields must be greater than or equal to zero'),
                'Wrong error message for ' + fieldName + ': ' + e.getMessage()
            );
        }
    }
    Test.stopTest();

    // Verify garden still has original valid values
    CAMPX__Garden__c finalGarden = [SELECT CAMPX__Minimum_Plant_Count__c, CAMPX__Max_Plant_Count__c,
                                   CAMPX__Total_Plant_Count__c, CAMPX__Total_Unhealthy_Plant_Count__c
                                   FROM CAMPX__Garden__c WHERE Id = :garden.Id];
    
    Assert.areEqual(1, finalGarden.CAMPX__Minimum_Plant_Count__c, 'Minimum Plant Count should remain 1');
    Assert.areEqual(100, finalGarden.CAMPX__Max_Plant_Count__c, 'Max Plant Count should remain 100');
    Assert.areEqual(0, finalGarden.CAMPX__Total_Plant_Count__c, 'Total Plant Count should remain 0');
    Assert.areEqual(0, finalGarden.CAMPX__Total_Unhealthy_Plant_Count__c, 'Unhealthy Plant Count should remain 0');
}

    @isTest
    private static void testValidPositiveValues() {
        // Test data with valid positive values
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Valid Garden',
            CAMPX__Minimum_Plant_Count__c = 1,
            CAMPX__Max_Plant_Count__c = 100,
            CAMPX__Total_Plant_Count__c = 50,
            CAMPX__Total_Unhealthy_Plant_Count__c = 5
        );
        
        Test.startTest();
        try {
            insert garden;
            // Query to verify the insert was successful
            CAMPX__Garden__c insertedGarden = [
                SELECT Id, CAMPX__Minimum_Plant_Count__c, CAMPX__Max_Plant_Count__c,
                    CAMPX__Total_Plant_Count__c, CAMPX__Total_Unhealthy_Plant_Count__c
                FROM CAMPX__Garden__c
                WHERE Id = :garden.Id
            ];
            
            // Verify all values were inserted correctly
            System.assertEquals(1, insertedGarden.CAMPX__Minimum_Plant_Count__c);
            System.assertEquals(100, insertedGarden.CAMPX__Max_Plant_Count__c);
            System.assertEquals(50, insertedGarden.CAMPX__Total_Plant_Count__c);
            System.assertEquals(5, insertedGarden.CAMPX__Total_Unhealthy_Plant_Count__c);
        } catch (Exception e) {
            System.assert(false, 'Should not have thrown an exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    private static void testAvoidNullValuesInMinMaxPlantCount() {
        // Create garden with valid values
        CAMPX__Garden__c garden = new CAMPX__Garden__c(
            Name = 'Test Garden',
            CAMPX__Minimum_Plant_Count__c = 1,
            CAMPX__Max_Plant_Count__c = 100,
            CAMPX__Total_Plant_Count__c = 50,
            CAMPX__Total_Unhealthy_Plant_Count__c = 0
        );
        insert garden;
        
        // Test different value scenarios
        Map<String, Decimal> fieldTests = new Map<String, Decimal>{
            'CAMPX__Minimum_Plant_Count__c' => null,
            'CAMPX__Max_Plant_Count__c' => null
        };
    
        Test.startTest();
        for(String fieldName : fieldTests.keySet()) {
            try {
                // Reset garden to valid values
                garden = [SELECT Id, Name, CAMPX__Minimum_Plant_Count__c, CAMPX__Max_Plant_Count__c, 
                         CAMPX__Total_Plant_Count__c, CAMPX__Total_Unhealthy_Plant_Count__c 
                         FROM CAMPX__Garden__c WHERE Id = :garden.Id];
                
                // Set null value for current field
                garden.put(fieldName, fieldTests.get(fieldName));
                update garden;
                
                Assert.fail('Expected exception for negative value in ' + fieldName + ' was not thrown');
            } catch (DmlException e) {
                // Verify error message
                Assert.isTrue(
                    e.getMessage().contains('Maximum and Minimum Plant Count fields cannot be blank when there are plants in the Garden.'),
                    'Wrong error message for ' + fieldName + ': ' + e.getMessage()
                );
            }
        }
        Test.stopTest();
    }

    @isTest
    private static void testInRangeValuesForMinMaxPlantCount() {
        // Test 1: Min > Max should throw error
        CAMPX__Garden__c garden1 = new CAMPX__Garden__c(
            Name = 'Invalid Garden',
            CAMPX__Minimum_Plant_Count__c = 100,
            CAMPX__Max_Plant_Count__c = 50
        );
        
        Test.startTest();
        try {
            insert garden1;
            Assert.fail('Should have thrown error for min > max');
        } catch(DmlException e) {
            Assert.isTrue(e.getMessage().contains('The Maximum Plant Count must be greater than or equal to the Minimum Plant Count'));
        }

        // Test 2: Min = Max should succeed
        CAMPX__Garden__c garden2 = new CAMPX__Garden__c(
            Name = 'Valid Garden Equal',
            CAMPX__Minimum_Plant_Count__c = 50,
            CAMPX__Max_Plant_Count__c = 50
        );
        
        try {
            insert garden2;
            CAMPX__Garden__c inserted = [SELECT Id FROM CAMPX__Garden__c WHERE Name = 'Valid Garden Equal'];
            Assert.isNotNull(inserted);
        } catch(Exception e) {
            Assert.fail('Should not throw error when min = max');
        }

        // Test 3: Min < Max should succeed
        CAMPX__Garden__c garden3 = new CAMPX__Garden__c(
            Name = 'Valid Garden Less',
            CAMPX__Minimum_Plant_Count__c = 25,
            CAMPX__Max_Plant_Count__c = 50
        );
        
        try {
            insert garden3;
            CAMPX__Garden__c inserted = [SELECT Id FROM CAMPX__Garden__c WHERE Name = 'Valid Garden Less'];
            Assert.isNotNull(inserted);
        } catch(Exception e) {
            Assert.fail('Should not throw error when min < max');
        }
        Test.stopTest();
    }
}