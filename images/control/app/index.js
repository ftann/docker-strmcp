import {Builder, Capabilities} from "selenium-webdriver";
import {video1} from "./flows/example"

function createContext() {
    return {
        endpoint: {
            host: process.env.SC_CONTROL_DRIVER_HOST,
            port: process.env.SC_CONTROL_DRIVER_PORT,
            user: process.env.SC_CONTROL_USER,
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
    const capabilities = Capabilities.firefox();
    const driver = new Builder()
        .usingServer(`http://${context.endpoint.host}:${context.endpoint.port}`)
        .withCapabilities(capabilities)
        .build();

    try {
        await flow(context, driver)
    } finally {
        driver.quit()
    }
}

performFlow(video1).catch(err => console.log("failed:", err))
