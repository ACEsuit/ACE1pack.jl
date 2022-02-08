
using ACE1pack, Pkg
using Pkg.Artifacts

artifacts_toml = joinpath(pathof(ACE1pack)[1:end-16], "Artifacts.toml")

function generate_artifact(label, zipname, url)
    data_hash = artifact_hash(label, artifacts_toml)

    if data_hash == nothing || !artifact_exists(data_hash)
        tarfile = download(url, @__DIR__() * "/" * zipname)
        hash_ = create_artifact() do artifact_dir
            cp(tarfile, joinpath(artifact_dir, zipname))
        end
        tarball_hash = archive_artifact(hash_, joinpath(tarfile))
        bind_artifact!(artifacts_toml, label, hash_,
                    download_info = [ (url, tarball_hash) ], lazy=true, force=true)
    end
end


label = "TiAl_tiny_dataset"
zipname = "TiAl_tiny.zip"
url = "https://github.com/gelzinyte/test_julia_artifacts/blob/main/$(zipname)?raw=true"
generate_artifact(label, zipname, url)

label = "ACE1pack_test_files"
zipname = "ACE1pack_test_files.zip"
url = "https://github.com/gelzinyte/test_julia_artifacts/blob/main/$(zipname)?raw=true"
generate_artifact(label, zipname, url)


#---
# testing the artifacts

using ACE1pack, Pkg
using Pkg.Artifacts

#---
# mock training set

tial_zip = joinpath(artifact"TiAl_tiny_dataset", "TiAl_tiny.zip")
run(`unzip $tial_zip`)
tial = "TiAl_tiny.xyz"
configs =  IPFitting.Data.read_xyz(tial;
    energy_key = "energy",
    force_key = "force",
    virial_key = "virial")

#---
# test files

test_files_zip = joinpath(artifact"ACE1pack_test_files", "ACE1pack_test_files.zip")
run(`unzip $test_files_zip`)

errors_fname = "expected_fit_errors.json"
errors_dict = load_dict(errors_fname)

