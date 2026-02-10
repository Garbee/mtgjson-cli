const dictionaryDefinitions = [
    {
        "name": "project-words",
        "path": "./etc/cspell/words.txt"
    },
    {
        "name": "third-party-names",
        "path": "./etc/cspell/third-party-names.txt"
    }
];

export default {
    // Version of the setting file.  Always 0.2
    "version": "0.2",
    "language": "en_US",
    "dictionaryDefinitions": dictionaryDefinitions,
    "dictionaries": [
        "bash",
        "companies",
        "docker",
        "filetypes",
        "git",
        "golang",
        "misc",
        "node",
        "shell",
        "software-terms",
        "softwareTerms",
        "typescript",

        ...dictionaryDefinitions.map(def => def.name)
    ]
}
