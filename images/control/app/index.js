import {Builder, Capabilities} from "selenium-webdriver";
import {video1} from "./flows/example"

const captureHost = process.env.SC_CONTROL_DRIVER_HOST
const capturePort = process.env.SC_CONTROL_DRIVER_PORT
const captureUser = process.env.SC_CONTROL_USER
const capturePassword = process.env.SC_CONTROL_PASSWORD

async function performFlow(flow) {

    const capabilities = Capabilities.firefox();
    const driver = new Builder()
        .usingServer(`http://${captureHost}:${capturePort}`)
        .withCapabilities(capabilities)
        .build();

    try {
        await flow(driver)
    } finally {
        driver.quit()
    }
}

performFlow(video1)
    .then(_ => {
        console.log("done")
    })
    .catch(reason => {
        console.error("failed", reason)
    })
