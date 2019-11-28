@IsTest
public with sharing class OneClassTest {
    @IsTest
    public static void shouldGetAClassName() {
        OneClass cls = new OneClass();

        String className = cls.getClassName();

        System.assertEquals('OneClass', className);
    }
}
