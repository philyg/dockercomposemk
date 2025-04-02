#implSep
#impl      "Target Name"   "Description"                                      "Command" ["Command"...]
#cust      "Target Name"   "Description"

impl       up              "Create and start containers in background"        "$DC up -d"
impl       fup             "Create and start containers in foreground"        "$DC up"
impl       down            "Stop and remove containers and remove orphans"    "$DC down --remove-orphans"

implSep
impl       start           "Start stopped containers"                         "$DC start"
impl       stop            "Stop started containers"                          "$DC stop"
impl       restart         "Restart containers"                               "$DC restart"

implSep
impl       pause           "Pause containers"                                 "$DC pause"
impl       unpause         "Unpause containers"                               "$DC unpause"

implSep
impl       shell           "Open shell to first container if running"         "$DC exec $SVC bash || true"
impl       run             "Open shell to first container image"              "$DC run --rm $SVC bash || true"

implSep
impl       stats           "Show running status information"                  "$DC stats || true"
impl       ps              "Show container list"                              "$DC ps -a || true"
impl       logs            "Display and follow logs"                          "$DC logs --tail 1000 -f || true"

implSep
impl       build           "Build any buildable images"                       "$DC build"
impl       pull            "Pull any non-buildable images"                    "$DC pull --ignore-buildable"
impl       rebuild         "Build any buildable images (no-cache)"            "$DC build --no-cache"

cust       reload          "Reload the service(s)"
cust       clean           "Cleanup any superfluous files"
cust       backup          "(Prepare for) backup of service data"
