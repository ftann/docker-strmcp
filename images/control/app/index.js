import {Browser, Builder} from "selenium-webdriver";
import firefox from "selenium-webdriver/firefox";
import {video1} from "./flows/video1"

function createContext() {
    return {
        endpoint: {
            host: process.env.SC_CONTROL_DRIVER_HOST,
            port: process.env.SC_CONTROL_DRIVER_PORT,
            username: process.env.SC_CONTROL_USERNAME,
            password: process.env.SC_CONTROL_PASSWORD,
        },
        screen: {
            width: parseInt(process.env.SC_CAPTURE_SCREEN_WIDTH, 10),
            height: parseInt(process.env.SC_CAPTURE_SCREEN_HEIGHT, 10),
        },
    }
}

async function performFlow(flow) {

    const context = createContext()
    const options = new firefox.Options()
        .setPreference("media.eme.enabled", true)
        .setPreference("media.gmp-manager.updateEnabled", true);
    const driver = new Builder()
        .usingServer(`http://${context.endpoint.host}:${context.endpoint.port}`)
        .forBrowser(Browser.FIREFOX)
        .setFirefoxOptions(options)
        .build();

    try {
        await flow(context, driver)
    } finally {
        driver.quit()
    }
}

performFlow(video1).catch(err => console.log("failed:", err))
