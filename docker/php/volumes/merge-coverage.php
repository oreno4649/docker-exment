<?php

declare(strict_types=1);

use SebastianBergmann\CodeCoverage\CodeCoverage;
use SebastianBergmann\CodeCoverage\Report\Clover;
use SebastianBergmann\CodeCoverage\Report\Html\Facade as HtmlFacade;
use SebastianBergmann\CodeCoverage\Report\Text;
use SebastianBergmann\CodeCoverage\Report\Thresholds;

$root = '/var/www/exment';
require $root . '/vendor/autoload.php';

$covDir = $argv[1] ?? $root . '/storage/logs/coverage';
$outDir = $argv[2] ?? $covDir . '/merged';

if (!is_dir($outDir)) {
    mkdir($outDir, 0777, true);
}

$files = glob($covDir . '/*.cov') ?: [];
if (!$files) {
    fwrite(STDERR, "no .cov files found in {$covDir}\n");
    exit(1);
}

/** @var CodeCoverage|null $merged */
$merged = null;
foreach ($files as $file) {
    fwrite(STDERR, "loading {$file}\n");
    /** @var CodeCoverage $cov */
    $cov = require $file;

    if ($merged === null) {
        $merged = $cov;
        continue;
    }
    $merged->merge($cov);
}

if ($merged === null) {
    fwrite(STDERR, "no coverage loaded\n");
    exit(1);
}

(new Clover())->process($merged, $outDir . '/clover.xml');
(new HtmlFacade())->process($merged, $outDir . '/html');

$summary = (new Text(Thresholds::default(), false, true))->process($merged, false);
file_put_contents($outDir . '/summary.txt', $summary);

echo $summary;
echo "\n";
echo "merged clover: {$outDir}/clover.xml\n";
echo "merged html:   {$outDir}/html/index.html\n";
