#! /usr/local/bin/node
 
var target_files = [
    'libglib-2.0.0.dylib'
];

var dir_from = '/Users/eirny/Work/GNOME/lib/';
var dir_to = '/Users/eirny/Developer/libs/';

var forceCopy = false;  // 파일이 이미 존재하여도 강제 복사

var rpathPrefix = '@rpath/';


/////////////////////////////////////////////////
// Process arguments
var argv = require('minimist')(process.argv.slice(2));
if (argv.from)  dir_from = argv.from;
if (argv.to)    dir_to = argv.to;
if (argv.force)	forceCopy = true;
if (argv.prefix) rpathPrefix= argv.prefix;
if (argv._)     target_files = argv._;
if (argv.h || argv.help)
{
    console.log('\nUsage:\n    rpathize.js <options> files_list_separated_by_space');
	console.log('Options:');
	console.log('   --force                force to copy files');
	console.log('   --from <directory>     directory path to find files');
	console.log('   --to <directory>       destination path to copy files');
	console.log('   --prefix <prefix>      rpath prefix (e.g: @rpath/lib)');
	console.log('');
    process.exit(0);
}
console.log('from dir: '+dir_from);
console.log('  to dir: '+dir_to);
console.log('  prefix: '+rpathPrefix);
console.log('    fore: '+forceCopy);
console.log('   files: ',target_files);

////////////////////////////////////////////////

var completes = Array();

var exec = require('child_process').exec;
var fs = require('fs');


if (!next_rpathize())
    process.exit(0);

function next_rpathize()
{
    var tg = target_files.pop();
    if (!tg)
        return false;

    // console.log('- '+tg);
        
    if (!arrayContains(completes, tg))
        rpathize(tg);
    
    return true;
}

function rpathize(dylib_file){
    var file_from = dir_from + '/' + dylib_file;
    var file_to = dir_to + '/' + dylib_file;

    fs.stat(file_from, function(err, stats) {
        if (err)
        {
            console.log('File not found: '+dylib_file, err);
            process.exit(1);
            return;
        }
        
        if (!stats.isFile())
            return;
        
        fs.stat(file_to, function(err, toStats) {
            var needCopy = false;
            if (err && err.code == 'ENOENT') {
                // 파일이 존재하지 않는다면 복사한다.
                needCopy = true;
            } else if (err == null) {
                // 파일이 존재한다면 시간을 비교한다.
                if (toStats.mtime < stats.mtime || forceCopy)
                    needCopy = true;

            } else {
                console.log('error fstat', err);
                porcess.exit(1)
                return;
            }
            
            if (needCopy) {                
                // 파일을 복사한다.
				var cmd_cp = 'cp ' + file_from.replace(/ /g, '\\ ') + ' ' + file_to.replace(/ /g, '\\ ');
                var op_cp = exec(cmd_cp, function(err, stdout, stderr){
                    if (err)
                    {
                        console.log('error cmd:', cmd_cp, err);
                        process.exit(1);
                        return;
                    }
                });

                // 복사가 완료되면
                op_cp.on('close', function(){
                    if (op_cp.exitCode != 0)
                    {
                        process.exit(1);
                        console.log('error on cp', err);
                        return;
                    }

                    console.log('Copy ' + dylib_file);

                    // 복사가 완료되면 완료 목록에 추가한다.
                    completes.push(dylib_file);
                    rpathize_otool(dylib_file, true);
                });
            } else {
                console.log('Check ' + dylib_file);

                // 완료 복록에 추가한다.
                completes.push(dylib_file);
                rpathize_otool(dylib_file, false);
            }
        });
    });
}

var install_names_cmds = [];

function rpathize_otool(dylib_file, stale) {
        
    var otoolResult = '';
    
    // 복사된 파일에 대하여 otool -L 을 시행한다.
	var cmd_op = 'otool -L '+dir_to.replace(/ /g, '\\ ')+'/'+dylib_file;
    var op_otool = exec(cmd_op, null, function(err, stdout, stderr){
        if (err)
        {
            console.log('error cmd:', cmd_op, err);
            process.exit(1);
            return;
        }
    });    

    // otool -L 의 결과 출력을 저장해 둔다
    op_otool.stdout.on('data', function(data){
        otoolResult += data;
    });
    
    // otool -L 의 실행이 완료되면
    op_otool.on('close', function(){
        if (op_otool.exitCode != 0)
        {
            console.log('error on otool', err);
            process.exit(1);
            return;
        }
        
        var symbols = otoolResult.split('\n');
                
        symbols.forEach(function(val, index, arr) {
            val = val.trim();

			// 첫번째 라인은 파일 자신의 이름을 출력하므로 무시한다.
            if (index == 0 || val == '') // skip first and last line
                return;
            
            var sym = val.split(' ', 1);
            var dep = sym[0].trim();
            
            // 동일 디렉터리에 존재하는 의존성 라이브러리일 경우
            if (dep.indexOf(dir_from) == 0) {
                dep_fname = dep.substring(dir_from.length);

                if (!arrayContains(target_files, dep_fname) && !arrayContains(completes, dep_fname))
                {
                    // console.log('++ ' + dep_fname);
                    target_files.push(dep_fname);
                }
                
                var cmd;
                if (dep_fname == dylib_file)
                    cmd = 'install_name_tool -id '+ rpathPrefix + dep_fname + ' ' + dir_to.replace(/ /g, '\\ ')+'/'+dylib_file;
                else
					cmd = 'install_name_tool -change ' + dep + ' '+ rpathPrefix + dep_fname + ' ' + dir_to.replace(/ /g, '\\ ')+'/'+dylib_file;

				install_names_cmds.push(cmd);

            // 신규로 복사된 파일이 아니라 이미 존재하는 파일일경우 이미 install_name_tool이 적용되었다
            } else if (dep.indexOf(rpathPrefix) == 0) {
                dep_fname = dep.substring(rpathPrefix.length);
                
                console.log('    ' + dep);
                
                if (!arrayContains(target_files, dep_fname) && !arrayContains(completes, dep_fname))
                {
                    // console.log('+- ' + dep_fname);
                    target_files.push(dep_fname);
                }
            }
        });

		next_install_name();
    });
}

function next_install_name()
{
	var cmd = install_names_cmds.pop();
	if (!cmd)
	{
		//console.log('Done. ' + dylib_file);
		console.log('Done.');

		if (target_files.length > 0)
		{
			if (!next_rpathize())
				process.exit(0);
		}
		return;
	}

	console.log('    ' + cmd);

	// multi process가 동일 파일에 install_name_tool을 적용할 때 누락되는 경우가 발생하는가?
	var op_install_name_tool = exec(cmd, null, function(err, stdout, stderr){
								if (err)
								{
									console.log('error exec install_name_tool', err);
									process.exit(1);
									return;
								}
							});

	op_install_name_tool.on('close', function(){
		next_install_name();
	});
}

function arrayContains(array, item)
{
    for (var i = 0; i < array.length; i++)
        if (array[i] == item)
            return true;
    return false;
}