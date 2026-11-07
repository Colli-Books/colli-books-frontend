package com.colli.books;

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import pl.leancode.patrol.PatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameterized.Parameters(name = "{0}")
    public static Object[] listDartTests() {
        PatrolJUnitRunner runner = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        runner.setUp(MainActivity.class);
        runner.waitForPatrolAppService();
        return runner.listDartTests();
    }

    private final String dartTest;

    public MainActivityTest(String dartTest) {
        this.dartTest = dartTest;
    }

    @Test
    public void runDartTest() {
        PatrolJUnitRunner runner = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        runner.runDartTest(dartTest);
    }
}
