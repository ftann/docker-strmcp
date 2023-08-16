export async function webgl1({screen: {width, height}}, driver) {
    await driver.manage().window().setRect({x: 0, y: 0, width, height})
    await driver.get("https://webglsamples.org/field/field.html");
}
