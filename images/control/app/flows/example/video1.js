import {By} from "selenium-webdriver";

const screenWidth = parseInt(process.env.SC_CAPTURE_SCREEN_WIDTH, 10)
const screenHeight = parseInt(process.env.SC_CAPTURE_SCREEN_HEIGHT, 10)

//const url = "https://www.bowlengarten.ch/";

const url = "https://videojs.github.io/autoplay-tests/plain/attr/autoplay.html";

async function maximize(driver) {
    await driver.manage().window().setRect({x: 0, y: 0, width: screenWidth, height: screenHeight})
}

async function startVideo(driver) {
    let video = driver.findElement(By.css("video"));
    const actions = driver.actions({async: true});
    await actions.move({origin: video}).click().perform();
}

export async function video1(driver) {
    await maximize(driver)
    await driver.get(url);
    await startVideo(driver)
}
