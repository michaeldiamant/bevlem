# Bevlem

Have you ever wondered how long PRs are sitting open?  I have been thinking about this topic and wrote bevlem to help me answer this question.  I am of the opinion that closing/merging PRs frequently is a healthy practice to minimize stale branches and to make life easier for PR reviewers.  Until now, I have not had a way to measure PR lifetime objectively.  Using bevlem, I am hoping to make it easier to objectively determine how PR lifetime is trending and where long PR lifetimes exist.

# Requirements
* jq v1.5.1+
* curl v7.47.0+ 

# Usage

`bash bevlem.sh <GITHUB_TOKEN> <USE_LOCAL_CACHE>`

`USE_LOCAL_CACHE` is a boolean.  Data pulled from github is stored in `/tmp`.  When using local cache, only local disk will be used (i.e. will not reach out to github).  Using local cache is helpful when re-running bevlem within a brief period of time.  This argument defaults to `false` (i.e. will reach out to github).

# Sample Output

```
michael@abroden:~/dev/bevlem$ bash bevlem.sh <REDACTED_GITHUB_TOKEN>
Repo               PR_Count  Min_Days  Max_Days  Mean_Days
akashi             2         9         29        19
ansible            7         0         29        10.142857142857142
goldengate         1         877       877       877
helix              0         N/A       N/A       N/A
hellgate           5         1         29        10.8
hellgate-external  2         1         86        43.5
k2                 1         4         4         4
kootenai           3         2         29        11.666666666666666
ota                2         14        66        40
ota-external       0         N/A       N/A       N/A
pierre             0         N/A       N/A       N/A
silvergate         0         N/A       N/A       N/A
threedollar        0         N/A       N/A       N/A
vasco              0         N/A       N/A       N/A
```

# Namesake
Bevlem is a portmanteau arising from the names of two cities on Boston's North Shore:  Beverly and Salem.  The [Veterans Memorial Bridge](https://en.wikipedia.org/wiki/Veterans_Memorial_Bridge_(Essex_County,_Massachusetts)), also called the Beverly-Salem Bridge is the inspiration for this project's name.  "Beverly-Salem" felt too unwieldy, hence "Bevlem"!
