pkg_name=apache-mod-jk
pkg_origin=franklinwebber
pkg_version="0.1.0"
pkg_maintainer="The Habitat Maintainers <humans@habitat.sh>"
pkg_license=('Apache-2.0')
pkg_version="1.2.42"
# pkg_source="http://some_source_url/releases/${pkg_name}-${pkg_version}.tar.gz"
pkg_source="http://download.nextag.com/apache/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.42-src.tar.gz"
pkg_filename="tomcat-connectors-${pkg_version}-src.tar.gz"
pkg_shasum="ea119f234c716649d4e7d4abd428852185b6b23a9205655e45554b88f01f3e31"

pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)
pkg_exports=(
  [port]=serverport
)
pkg_exposes=(port)

pkg_binds=(
  [tomcat]=port
)

pkg_svc_run="httpd -DFOREGROUND -f $pkg_svc_config_path/httpd.conf"
pkg_svc_user="root"
pkg_svc_group="root"

pkg_build_deps=( core/gcc core/make franklinwebber/httpd core/automake core/autoconf core/libtool core/perl )

pkg_deps=(core/httpd)

# Below is the default behavior for this callback. Anything you put in this
# callback will override this behavior. If you want to use default behavior
# delete this callback from your plan.
# @see https://www.habitat.sh/docs/reference/plan-syntax/#callbacks
# @see https://github.com/habitat-sh/habitat/blob/master/components/plan-build/bin/hab-plan-build.sh
do_build() {
    cd $HAB_CACHE_SRC_PATH/tomcat-connectors-1.2.42-src/native
    ./buildconf.sh
    # LDFLAGS=-lc ./configure

    ./configure --prefix=$pkg_prefix -with-apxs=$(pkg_path_for franklinwebber/httpd)/bin/apxs
    # ./configure --prefix=$pkg_prefix -with-apxs=$(pkg_path_for core/httpd)/bin/apxs

    make
}

# Below is the default behavior for this callback. Anything you put in this
# callback will override this behavior. If you want to use default behavior
# delete this callback from your plan.
# @see https://www.habitat.sh/docs/reference/plan-syntax/#callbacks
# @see https://github.com/habitat-sh/habitat/blob/master/components/plan-build/bin/hab-plan-build.sh
do_install() {
    cd $HAB_CACHE_SRC_PATH/tomcat-connectors-1.2.42-src/native
    mkdir -p $pkg_prefix/modules
    # cp apache-1.3/mod_jk.so $pkg_prefix/modules/
    cp apache-2.0/mod_jk.so $pkg_prefix/modules/
    # cp apache-2.0
    # copy the module in the apache install
}
