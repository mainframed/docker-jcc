# JCC Docker Container

This container is based on debian buster (10). It uses Paul Winters `jcc` which can be used to compile C programs for use on IBM mainframes.

The compiler is available here: https://github.com/mvslovers/jcc

## Building

run `docker build -t jcc .`

## Usage

The docker container has a volume setup at `/project`. To compile your C code located in `project/test.c` run

```bash
docker run -it -v $(pwd)/project:/code jcc jccc -I/jcc/include -o test.c
```

**Note**: This uses the bash script `jccc` since jcc does not allow you to control the object output folder.

Here's another example:

```bash
mkdir -p project

cat <<EOF >project/main.c
#include <stdio.h>
int main(int argv, char ** argc) {
    printf("Hello Docker from jcc!\n");
}
EOF

docker run -it -v $(pwd)/project:/project jcc jccc -I/jcc/include -o test.c
```

## rdrprep

This containter also comes with **rdrprep** available here: https://github.com/mainframed/rdrprep. You can use **rdrprep** to insert the jcc compiled object in to any ascii file. Below is an example usage:

```bash
cat << 'EOF' > project/rdrprep_template.jcl
//LINKCPRJ JOB (CPROJ),
//            'Link C program',
//            CLASS=A,
//            MSGCLASS=A,
//            REGION=8M,
//            MSGLEVEL=(1,1),
//            USER=IBMUSER,PASSWORD=SYS1
//LKED     EXEC PGM=IEWL,PARM='NCAL,MAP,LIST,XREF,NORENT'
//SYSUT1   DD UNIT=SYSDA,SPACE=(CYL,(5,2))
//SYSPRINT DD SYSOUT=*
//SYSLMOD  DD DSN=SYS2.LINKLIB(FTPD),DISP=SHR
//SYSLIN   DD DATA,DLM=$$
::E test.obj
$$
EOF
docker run -it -v $(pwd)/project:/project jcc rdrprep /project/rdrprep_template.jcl /project/outputjcl.ebcdic.jcl
```
