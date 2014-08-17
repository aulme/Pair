Function story ($story) {
    if($story) {
        setEnvVar "CURRENT_STORY" $story
        return
    }
    
    return safeGetEnvVar "CURRENT_STORY" "No story"
}

