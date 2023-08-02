#!/usr/bin/env -S node
// Created July 09. 2023
import { constants } from "fs"
import { access, open, stat } from "fs/promises"
import * as path from "path"
import { ok as assert } from "assert"
import { Transform } from "stream"
import { debug, log } from "node:console"

// import * as path from "node:path"
// import * as fs from 'node:fs/promises';
 
// import { log } from "node:console";

let Uniq = class extends Transform {
    static Set = Set
    constructor(opt){
        super(opt)
        this.urls = new this.constructor.Set();
        
        }
    _flush(callback){
        for (let listItem of this.urls) { 
            this.push(listItem + "\n")
        }
        callback(null)
    }
    _transform(chunk, encoding, callback){

        if(chunk == null) {
            return callback(null)
        }
        let chunkStr = ""
        if (encoding == "buffer") {
            chunkStr = chunk.toString("utf8");
            encoding = "utf8";
        }
        if (encoding != "utf8") {
            callback("invalid encoding, utf8 is expected")
            return
        }
        let linkedListItem = chunkStr.split("\n")
        let listItem;
        for (let imgI = 0; imgI < linkedListItem.length; imgI++) {
            listItem = linkedListItem[imgI]
            if(this.urls.has(listItem)){
                console.log("-> ", listItem)
            } else {
                this.urls.add(listItem)
            }
        }
        callback(null, "")
    }
}

let commandName = path.basename(process.argv[1]);
let inputFile   = process.argv[2];
let outputFile  = process.argv[3];

    assert(inputFile    ,":  input file name is required: " + commandName + " INFILE OUTFILE ");
    assert(outputFile   ,": output file name is required: " + commandName + " INFILE OUTFILE ");

let stats, inHandle, outHandle;
try {
                await access(inputFile, constants.F_OK);
    inHandle  = await open(inputFile, "r");
    outHandle = await open(outputFile, "w");
    stats     = await stat(inputFile);
 
let inputBuffer  = "";
let source = inHandle.createReadStream(inputFile, { encoding: "utf8" });
let uniqLines = new Uniq;
let dest   = outHandle.createWriteStream(outputFile, { encoding: "utf8" });
    source.pipe(uniqLines).pipe(dest)
    

} catch (err) {
    console.error(commandName, " has failed! aborting");
    console.error(err.message); 
}
// ex:expandtab
