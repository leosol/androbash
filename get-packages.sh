mkdir ./output/
cd ./output/

rm packages.txt
rm packages.sh
rm hidden-packages.txt
rm disabled-packages.txt
rm third-party-packages.txt
rm third-party-not-google-play.txt

adb shell dumpsys package|grep 'Package \['|cut -d [ -f 2|cut -d ] -f 1 > packages.txt

diff <(adb shell pm list packages -u) <(adb shell pm list packages) > hidden-packages.txt

adb shell pm list packages -d > disabled-packages.txt

adb shell pm list packages -3 -i > third-party-packages.txt

adb shell pm list packages -3 -i|grep -vi com.android.vending > third-party-not-google-play.txt

echo "">packages.sh
echo "">install-dates.txt
cat packages.txt | while read line
do
   echo $line
   echo "echo package $line >> install-dates.txt" >> packages.sh
   echo "adb shell 'dumpsys package $line  | grep -E \"firstInstallTime|lastUpdateTime|primaryCpuAbi|versionCode|versionName|dataDir|installerPackageName\"' >> install-dates.txt" >> packages.sh
done

echo "cat install-dates.txt|grep lastUpdateTime|cut -d = -f 2|cut -d ' ' -f 1|sort|uniq -c > lastUpdateTimes.txt" >> packages.sh
echo "cat install-dates.txt|grep firstInstallTime|cut -d = -f 2|cut -d ' ' -f 1|sort|uniq -c > firstInstallTime.txt" >> packages.sh
sh packages.sh
cd ..



