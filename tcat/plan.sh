pkg_origin=franklinwebber
pkg_name=tcat
pkg_version=0.1.0

pkg_deps=( core/jre8 core/tomcat7 )
pkg_exports=(
  [port]=server.port
)
pkg_exposes=(port)

# Below is the default behavior for this callback. Anything you put in this
# callback will override this behavior. If you want to use default behavior
# delete this callback from your plan.
# @see https://www.habitat.sh/docs/reference/plan-syntax/#callbacks
# @see https://github.com/habitat-sh/habitat/blob/master/components/plan-build/bin/hab-plan-build.sh
do_build() {
    return 0
}

# Below is the default behavior for this callback. Anything you put in this
# callback will override this behavior. If you want to use default behavior
# delete this callback from your plan.
# @see https://www.habitat.sh/docs/reference/plan-syntax/#callbacks
# @see https://github.com/habitat-sh/habitat/blob/master/components/plan-build/bin/hab-plan-build.sh
do_install() {
    return 0
}
