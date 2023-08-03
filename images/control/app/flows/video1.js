import {By} from "selenium-webdriver";

export async function video1({screen: {width, height}}, driver) {

    await driver.manage().window().setRect({x: 0, y: 0, width, height})

    await driver.get("https://videojs.github.io/autoplay-tests/plain/attr/autoplay.html");

    const video = await driver.findElement(By.css("video"));
    const actions = driver.actions({async: true});
    await actions.move({origin: video}).click().perform();
}
