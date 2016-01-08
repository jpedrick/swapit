" function definition.
if !exists( "g:LAUNCH_ROOT" )
    let g:swapit_root = getcwd()
    let g:swapit_header_extensions = 'hpp:h'
    let g:swapit_source_extensions = 'cpp:C:c:cc:cxx'
    let g:swapit_timeout = 5
    let g:swapit_log_level = 'error'
endif

function! Swapit()
python << EOF
import os, logging, types, re
import vim
import signal

__version__ = 1.0
__author__ = 'Joshua Pedrick/Jia Hongyuan'

headerExts = vim.eval('g:swapit_header_extensions').split(':')
sourceExts = vim.eval('g:swapit_source_extensions').split(':')
timeout    = int(vim.eval('g:swapit_timeout'))
log_level  = vim.eval('g:swapit_log_level')
inSearch = False

class LogLevel():
    off = 0
    error = 1 
    warn = 2
    info = 3 
    debug = 4

numeric_log_level = getattr(LogLevel,log_level)

def logPrint( mes, on=1 ):
    if type(mes)==types.NoneType:
        mes = 'NONE'
    if on <= numeric_log_level:
        print '--', mes

def recursiveSearch( parent, pattern ):
    logPrint( 'recursiveSearch( parent: %s, pattern: %s ):' % ( parent, pattern ), LogLevel.debug )
    for directory, dirnames, filenames in os.walk(parent):
        for filename in filenames:
            logPrint( 'checking if -> filename: %s matches pattern: %s' % ( filename,  pattern ), LogLevel.debug )
            if re.match( pattern, filename ):
                return os.path.abspath( '%s/%s'%(parent, filename) )
        for directory in dirnames:
            return recursiveSearch( directory, pattern )
    return None

def loadFileIntoVim( fn ):
    for b in vim.buffers:
        if os.path.samefile(b.name,fn):
            vim.current.buffer = b
            return True

    # load it
    try:
        cmd = 'e %s'% fn
        logPrint( 'cmd: '+cmd, LogLevel.info )
        vim.command( cmd )
        return True
    except Exception, e:
        print e
        return False

def swapitTimeoutHandler(signum, frame):
    if inSearch:
        raise Exception("Swapit timed out!")

def tryToSearchAndLoadFile( pattern ):
    inSearch = True
    signal.signal( signal.SIGALRM, swapitTimeoutHandler )
    signal.alarm(timeout)
    try:
        cwd = vim.eval('g:swapit_root')
        logPrint( 'current working root:'+cwd, LogLevel.debug )

        logPrint( 'search:'+cwd+', '+pattern, LogLevel.debug )
        targetFn = recursiveSearch( cwd, pattern )
        inSearch = False

        # test file
        if type(targetFn)!=types.NoneType:
            print 'loading first search:', targetFn 
            return loadFileIntoVim( targetFn )
        else:
            return False
    except Exception, msg:
        logPrint( 'tryToSearchAndLoadFile: exception thrown: [%s]' % msg, LogLevel.error )
        return False;

def tryToLoadFile( prefix, path, postfixes ):
    for postfix in postfixes:
        filename = '/'.join( [ path, prefix + '.' + postfix ] )
        logPrint( 'tryToLoadFile( prefix: %s, path: %s, postfixes: %s ) -> filename: %s' % ( prefix, path, postfixes, filename ), LogLevel.debug )
        if os.path.exists( filename ):
            return loadFileIntoVim( filename )
    return False

def run():
    curbuf_name = vim.current.buffer.name
    logPrint( 'current buf file:'+curbuf_name, LogLevel.debug )
    if curbuf_name=='':
        logPrint( 'Invalid action: attempted to switch unnamed file', LogLevel.error )
        return
    
    old_path, old_fn = os.path.split( curbuf_name )
    logPrint( 'Current buffer path: '+old_path + ' -> ' + old_fn, LogLevel.debug )

    tmp_fn = old_fn.split( '.' )
    tmp_ext = tmp_fn.pop()
    if tmp_ext in headerExts :
        # 1. search in current buffer file path
        st = tryToLoadFile( tmp_fn[0], old_path, sourceExts )
        if st:
            return True
        # 2. search in LAUNCH_ROOT
        pattern = '.'.join(tmp_fn) + '\.(' + '|'.join(sourceExts) + ')$'
        st = tryToSearchAndLoadFile(pattern)
        if st:
            return True

        return False

    elif tmp_ext in sourceExts:
        # 1. search in current buffer file path
        st = tryToLoadFile( tmp_fn[0], old_path, headerExts )
        if st:
            return True
        # 2. search in LAUNCH_ROOT
        pattern = '.'.join(tmp_fn) + '\.(' + '|'.join(headerExts) + ')$'
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

