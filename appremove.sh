#!/usr/bin/env bash
set -eu

declare -r ADB="${ADB:-adb}"
declare DEVICE="${DEVICE:-}"

if ! command -v "${ADB}" > /dev/null 2>&1; then
	printf 'エラー: %sコマンドが存在しません\n' "${ADB}" >&2
	exit 1
fi

if [[ -z "${DEVICE}" ]]; then
	declare -a _devices=()
	declare line _deviceserial _devicestatus
	while IFS=$'\n' read -rd $'\n' line; do
		_deviceserial="$(awk '{print $1;}' <(printf '%s' "${line}"))"
		_devicestatus="$(awk '{print $2;}' <(printf '%s' "${line}"))"
		if [[ ! "${_devicestatus}" == "device" ]]; then
			printf '警告: 端末"%s"をスキップしました(状態: "%s", 状態が"device"ではない端末はスキップされます)\n' "${_deviceserial}" "${_devicestatus}" >&2
			continue
		fi
		_devices+=("${_deviceserial}")
	done < <(adb devices | grep -v '^\(\|List of devices attached\)$')
	unset line _deviceserial _devicestatus

	case "${#_devices[@]}" in
		"0" )
			printf 'エラー: USBデバッグが有効な端末が見つかりません\n\tAndroid端末が正しく接続されているか確認してください\n' >&2
			exit 1
			;;
		"1" )
			DEVICE="${_devices[-1]}"
			;;
		* )
			printf '情報: 端末が複数接続されています。対象となる端末を選択してください:\n'
			declare _device
			for _device in "${_devices[@]}"; do
				printf '\t%s\n' "${_device}"
			done
			unset _device
			read -rd $'\n' -p '端末: ' DEVICE
			;;
	esac
	unset _devices
fi
readonly DEVICE

declare _result="" _command='true && echo OK'
set +e
IFS='' read -rd '' _result < <(adb -s "${DEVICE}" shell "${_command}" 2> /dev/null)
set -e
case "${_result}" in
	$'OK\n' | $'OK\r\n' ) ;;
	* )
		printf 'エラー: 端末"%s"でテストコマンドを正常に実行できませんでした (%s)\n' "${DEVICE}" "${_command}" >&2
		exit 1
		;;
esac
unset _result _command

declare -a PACKAGES=()
declare line
while IFS=$'\n' read -rd $'\n' line; do
	if [[ "${line}" =~ (docomo|ntt|auone|rakuten|kddi|softbank) ]]; then
		PACKAGES+=("${line}")
	fi
done < <(adb -s "${DEVICE}" shell pm list package | sed -e 's/^package://g')
unset line
readonly PACKAGES

if [[ "${#PACKAGES[@]}" == "0" ]]; then
	printf '情報: 対象となるアプリは端末"%s"に存在しませんでした\n' "${DEVICE}"
	exit 0
fi

printf '情報: 以下のアプリを消去します:\n'
declare _package
for _package in "${PACKAGES[@]}"; do
	printf '\t%s\n' "${_package}"
done
unset _package
declare _answer
read -rd '$\n' -p '続行しますか? [y/N]: ' _answer
case "${_answer}" in
	[Yy]* )
		printf 'アプリの消去を実行します…\n'
		declare _package
		for _package in "${PACKAGES[@]}"; do
			printf 'パッケージ: %s\n' "${_package}"
			set +e
			adb -s "${DEVICE}" shell pm uninstall "${_package}"
			set -e
		done
		printf '完了しました\n'
		;;
	* )
		printf '中断しました\n'
		;;
esac
unset _answer
