tasks.register("assembleDebug") {
    doLast {
        println("FFmpeg Maker build environment ready.")
    }
}

tasks.register("assembleRelease") {
    doLast {
        println("FFmpeg Maker release environment ready.")
    }
}
