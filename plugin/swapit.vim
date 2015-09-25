" function definition.
if !exists( "g:LAUNCH_ROOT" )
    let g:swapit_root = getcwd()
    let g:swapit_header_extensions = 'hpp:h'
    let g:swapit_source_extensions = 'cpp:C:c:cc:cxx'
endif

function! Swapit()
python << EOF
import os, logging, types, re
import vim

__version__ = 1.0
__author__ = 'Joshua Pedrick/Jia Hongyuan'

headerExts = vim.eval('g:swapit_header_extensions').split(':')
sourceExts = vim.eval('g:swapit_source_extensions').split(':')

# logger
DEBUG = 4
ERROR = 3
WARN  = 2
INFO  = 1
OFF   = 0
GLOBAL_LEVEL = OFF

def logPrint( mes, on=1 ):
    if type(mes)==types.NoneType:
        mes = 'NONE'
    if on<=GLOBAL_LEVEL:
        print '--', mes

def recursive_search( parent, pattern ):
    children = os.listdir( parent )
    for chi in children:
        if re.match( pattern, chi ):
            return os.path.abspath( '%s/%s'%(parent, chi) )
        else:
            nextParent = os.path.abspath( '%s/%s'%(parent, chi) )
            st = os.path.isdir(nextParent)
            if st:
                result = recursive_search( nextParent, pattern )
                if type(result)!=types.NoneType:
                    return result

def loadFileIntoVim( fn ):
    # load it
    try:
        cmd = 'e %s'% fn
        logPrint( 'cmd: '+cmd, INFO )
        vim.command( cmd )
        return True
    except Exception, e:
        print e
        return False

def tryToSearchAndLoadFile( pattern ):
    cwd = vim.eval('g:swapit_root')
    logPrint( 'current working root:'+cwd, DEBUG )

    logPrint( 'search:'+cwd+', '+pattern, DEBUG )
    targetFn = recursive_search( cwd, pattern )
    print 'first search:', targetFn 

    # test file
    if type(targetFn)!=types.NoneType:
        return loadFileIntoVim( targetFn )
    else:
        return False

def tryToLoadFile( fn, path ):
    fullName = '%s/%s' % ( path, fn )
    logPrint( 'Try to load:'+fullName, DEBUG )
    if os.path.exists( fullName ):
        return loadFileIntoVim( fullName )
    else:
        return False

def run():
    curbuf_name = vim.current.buffer.name
    logPrint( 'current buf file:'+curbuf_name, DEBUG )
    if curbuf_name=='':
        logPrint( 'Invalid action: attempted to switch unnamed file', ERROR )
        return
    
    old_path, old_fn = os.path.split( curbuf_name )
    logPrint( 'Current buffer path: '+old_path + ' -> ' + old_fn )

    tmp_fn = old_fn.split( '.' )
    tmp_ext = tmp_fn.pop()
    if tmp_ext in headerExts :
        pattern = '.'.join(tmp_fn) + '\.(' + '|'.join(sourceExts) + ')$'
        # 1. search in current buffer file path
        st = tryToLoadFile( pattern, old_path )
        if st:
            return True
        # 2. search in LAUNCH_ROOT
        st = tryToSearchAndLoadFile(pattern)
        if st:
            return True

        return False

    elif tmp_ext in sourceExts:
        pattern = '.'.join(tmp_fn) + '\.(' + '|'.join(headerExts) + ')$'
        # 1. search in current buffer file path
        st = tryToLoadFile( pattern, old_path )
        if st:
            return True
        # 2. search in LAUNCH_ROOT
        st = tryToSearchAndLoadFile( pattern )
        if st:
            return True

        return False
    else:
        logPrint( ' Unknown extension:'+curbuf_name )
        return False

run()

EOF
endfunction

