import commonjs from '@rollup/plugin-commonjs';
import json from '@rollup/plugin-json';
import resolve from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';

export default {
    input: 'index.js',
    output: {
        file: 'dist/control.js',
        format: 'cjs',
    },
    plugins: [
        resolve(),
        commonjs({
            dynamicRequireTargets: [
                "node_modules/selenium-webdriver/**/*.js",
            ]
        }),
        terser(),
        json()
    ]
};
