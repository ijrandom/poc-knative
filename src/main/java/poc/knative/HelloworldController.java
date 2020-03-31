package poc.knative;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Random;

@RestController
public class HelloworldController {
    private Random random = new Random();

    @GetMapping("/")
    public String hello() throws InterruptedException {
        long delay = Math.abs(random.nextLong() % 5000);
        Thread.sleep(delay);
        return "Delay: " + delay;
    }
}
