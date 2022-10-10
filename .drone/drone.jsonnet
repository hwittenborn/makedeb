local runUnitTests(pkgname, tag) = {
    name: "run-unit-tests-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},

    steps: [{
        name: "run-unit-tests",
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-focal",
        environment: {
            release_type: tag,
            pkgname: pkgname
        },
        commands: [
            ".drone/scripts/install-deps.sh",
            "sudo chown 'makedeb:makedeb' ../ -R",
            ".drone/scripts/run-unit-tests.sh"
        ]
    }]
};

local createTag(tag) = {
    name: "create-tag-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["run-unit-tests-" + tag],
    steps: [{
        name: tag,
        image: "ubuntu:20.04",
        environment: {
            github_api_key: {from_secret: "github_api_key"}
        },
        commands: [
            ".drone/scripts/create_tag.sh"
        ]
    }]
};

local buildAndPublish(pkgname, tag) = {
    name: "build-and-publish-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["create-tag-" + tag],
    steps: [
        {
            name: "build-debian-package",
            image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-focal",
            environment: {
                release_type: tag,
                pkgname: pkgname
            },
            commands: [
                ".drone/scripts/install-deps.sh",
                "sudo chown 'makedeb:makedeb' ../ -R",
                ".drone/scripts/build.sh"
            ]
        },

        {
            name: "publish-proget",
            image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-focal",
            environment: {proget_api_key: {from_secret: "proget_api_key"}},
            commands: [
                ".drone/scripts/install-deps.sh",
                ".drone/scripts/publish.py"
            ]
        }
    ]
};

local userRepoPublish(pkgname, tag, user_repo) = {
    name: user_repo + "-publish-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["create-tag-" + tag, "build-and-publish-" + tag],
    steps: [{
        name: pkgname,
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-focal",
        environment: {
            ssh_key: {from_secret: "ssh_key"},
            package_name: pkgname,
            release_type: tag,
            target_repo: user_repo
        },
        commands: [
            ".drone/scripts/install-deps.sh",
            ".drone/scripts/user-repo.sh"
        ]
    }]
};

local sendBuildNotification(tag) = {
    name: "send-build-notification-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {
        branch: [tag],
        status: ["success", "failure"]
    },
    depends_on: [
        "build-and-publish-" + tag,
        "mpr-publish-" + tag
    ],
    steps: [{
        name: "send-notification",
        image: "proget.hunterwittenborn.com/docker/hwittenborn/drone-matrix",
        settings: {
            username: "drone",
            password: {from_secret: "matrix_api_key"},
            homeserver: "https://matrix.hunterwittenborn.com",
            room: "#makedeb-ci-logs:hunterwittenborn.com"
        }
    }]
};

local buildForMentors(pkgname, tag) = {
    name: "build-for-mentors-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["create-tag-" + tag],
    steps: [{
        name: "publish-mentors",
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-focal",
        environment: {
            debian_packaging_key: {from_secret: "debian_packaging_key"},
            pkgname: pkgname
        },
        when: {branch: ["stable"]},
        commands: [
            ".drone/scripts/install-deps.sh",
            ".drone/scripts/mentors.sh"
        ]
    }]
};

[
    runUnitTests("makedeb", "stable"),
    runUnitTests("makedeb-beta", "beta"),
    runUnitTests("makedeb-alpha", "alpha"),

    createTag("stable"),
    createTag("beta"),
    createTag("alpha"),

    buildAndPublish("makedeb", "stable"),
    buildAndPublish("makedeb-beta", "beta"),
    buildAndPublish("makedeb-alpha", "alpha"),

    userRepoPublish("makedeb", "stable", "mpr"),
    userRepoPublish("makedeb-beta", "beta", "mpr"),
    userRepoPublish("makedeb-alpha", "alpha", "mpr"),

    sendBuildNotification("stable"),
    sendBuildNotification("beta"),
    sendBuildNotification("alpha"),
    
    buildForMentors("makedeb", "stable")
]

// vim: set syntax=typescript ts=4 sw=4 expandtab:
