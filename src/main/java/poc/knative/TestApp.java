package poc.knative;

import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

public class TestApp {

    public static final int COUNT = 1000;
    public static final int THREAD_COUNT = 1000;

    public static void main(String[] args) throws InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(THREAD_COUNT);
        AtomicLong total = new AtomicLong();
        long ss = System.currentTimeMillis();
        for (int i = 0; i < COUNT; ++i) {
            int n = i;
            executorService.submit(() -> {
                execute(n);
            });
        }
        executorService.shutdown();
        executorService.awaitTermination(1, TimeUnit.DAYS);
        long ee = System.currentTimeMillis();
        System.out.println("Total: " + (ee - ss) / COUNT);
    }

    private static void execute(int n) {
        try {
            HttpURLConnection connection = (HttpURLConnection) new URL("http://poc-knative.default.example.com").openConnection();
            connection.setRequestProperty("Host", "poc-knative.default.example.com");
            int code = connection.getResponseCode();
            if (code != 200) {
                System.err.println("Failed at " + n + ". Code: " + code);
                return;
            }
            System.out.printf("%d: Ok\n", n);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
