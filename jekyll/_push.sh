#!/bin/bash

s3cmd sync -c ~/.s3cfg --delete-removed ./_site/ s3://1000monkeys.co/ 