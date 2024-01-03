

mkdir ./output/
cd ./output/
rm -rf APK

mkdir APK

rm packages.txt
rm packages.sh
rm hidden-packages.txt
rm disabled-packages.txt
rm third-party-packages.txt
rm third-party-not-google-play.txt
rm get-apks.sh

adb shell dumpsys package|grep 'Package \['|cut -d [ -f 2|cut -d ] -f 1 > packages.txt

diff <(adb shell pm list packages -u) <(adb shell pm list packages) > hidden-packages.txt

adb shell pm list packages -d > disabled-packages.txt

adb shell pm list packages -3 -i > third-party-packages.txt

adb shell pm list packages -3 -i|grep -vi com.android.vending > third-party-not-google-play.txt

echo "">packages.sh
echo "">install-dates.txt

cat packages.txt | while read line;
do
   #echo $line
   pkg_path=` adb shell pm path $line < /dev/null|head -1|cut -d ':' -f 2 `;
   #echo "Script to download $line";
   echo "adb pull $pkg_path ./APK/$line.apk;" >> get-apks.sh
done

cat packages.txt | while read line
do
   echo $line
   echo "echo package $line >> install-dates.txt" >> packages.sh
   echo "adb shell 'dumpsys package $line  | grep -E \"firstInstallTime|lastUpdateTime|primaryCpuAbi|versionCode|versionName|dataDir|installerPackageName\"' >> install-dates.txt" >> packages.sh
done

echo "cat install-dates.txt|grep lastUpdateTime|cut -d = -f 2|cut -d ' ' -f 1|sort|uniq -c > lastUpdateTimes.txt" >> packages.sh
echo "cat install-dates.txt|grep firstInstallTime|cut -d = -f 2|cut -d ' ' -f 1|sort|uniq -c > firstInstallTime.txt" >> packages.sh
bash packages.sh

printf 'download apks (y/n)? '
read answer
if [ "$answer" != "${answer#[Yy]}" ] ;then 
    bash get-apks.sh;
else
    echo "Skipping..."
fi

cd ..



