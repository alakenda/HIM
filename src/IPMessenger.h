/*============================================================================*
 * (C) 2001-2011 G.Ishiwata, All Rights Reserved.
 *
 *	Project		: IP Messenger for Mac OS X
 *	File		: IPMessenger.h
 *	Module		: 共通ヘッダ
 *	Description	: IPMsg共通定義
 *============================================================================*/

/*============================================================================*
 * IP Messenger プロトコル定義（IPMessenger for Win32 v3.00 ipmsg.hから引用）
 *============================================================================*/

/*  IP Messenger Communication Protocol version 3.0 define  */
/*  macro  */
#define GET_MODE(command)	(command & 0x000000ffUL)
#define GET_OPT(command)	(command & 0xffffff00UL)

/*  header  */
#define IPMSG_VERSION			0x0001
#define IPMSG_DEFAULT_PORT		0x0979

//mac地址必须大写
#define FEIQ_AVATAR "#0#0#0"
//有太阳标识
#define FEIQ_VERSION  "_lbt4_51#32899"
//无太阳标识
//#define FEIQ_VERSION  "_lbt4_51#128"
//#define FEIQ_VERSION  "_lbt4_51#32899#10DDB1DE19CD#0#0#0"
/*  command  */
#define IPMSG_NOOPERATION		0x00000000UL

#define IPMSG_BR_ENTRY			0x00000001UL
#define IPMSG_BR_EXIT			0x00000002UL
#define IPMSG_ANSENTRY			0x00000003UL
#define IPMSG_BR_ABSENCE		0x00000004UL

#define IPMSG_BR_ISGETLIST		0x00000010UL
#define IPMSG_OKGETLIST			0x00000011UL
#define IPMSG_GETLIST			0x00000012UL
#define IPMSG_ANSLIST			0x00000013UL
#define IPMSG_BR_ISGETLIST2		0x00000018UL

//发送文本消息
#define IPMSG_SENDMSG			0x00000020UL
//文本消息确认包
#define IPMSG_RECVMSG			0x00000021UL
#define IPMSG_READMSG			0x00000030UL
//键盘正在输入状态
#define IPMSG_INPUTMSG			0x00000079UL
#define IPMSG_DELMSG			0x00000031UL
#define IPMSG_ANSREADMSG		0x00000032UL

#define IPMSG_GETINFO			0x00000040UL
#define IPMSG_SENDINFO			0x00000041UL

#define IPMSG_GETABSENCEINFO	0x00000050UL
#define IPMSG_SENDABSENCEINFO	0x00000051UL

//获取附件数据(TCP)
#define IPMSG_GETFILEDATA		0x00000060UL
#define IPMSG_RELEASEFILES		0x00000061UL
#define IPMSG_GETDIRFILES		0x00000062UL

#define IPMSG_GETPUBKEY			0x00000072UL
#define IPMSG_ANSPUBKEY			0x00000073UL
//屏幕截图
#define IPMSG_SENDSCREENSHOT    0x000000C0UL
//屏幕截图确认包
#define IPMSG_RECVSCREENSHOT    0x000000C1UL

//屏幕震动包
#define IPMSG_SCREENSHAKE       0x000000D1UL
//屏幕震动回应包
#define IPMSG_ACK_SCREENSHAKE   0x000000D2UL

/*  option for all command  */
//外出
#define IPMSG_ABSENCEOPT		0x00000100UL
#define IPMSG_SERVEROPT			0x00000200UL
#define IPMSG_DIALUPOPT			0x00010000UL
//携带附件
#define IPMSG_FILEATTACHOPT		0x00200000UL
#define IPMSG_ENCRYPTOPT		0x00400000UL
#define IPMSG_UTF8OPT			0x00800000UL
#define IPMSG_CAPUTF8OPT		0x01000000UL
#define IPMSG_ENCEXTMSGOPT		0x04000000UL
#define IPMSG_CLIPBOARDOPT		0x08000000UL

/*  option for send command  */
#define IPMSG_SENDCHECKOPT		0x00000100UL
#define IPMSG_SECRETOPT			0x00000200UL
#define IPMSG_BROADCASTOPT		0x00000400UL
#define IPMSG_MULTICASTOPT		0x00000800UL
#define IPMSG_AUTORETOPT		0x00002000UL
#define IPMSG_RETRYOPT			0x00004000UL
#define IPMSG_PASSWORDOPT		0x00008000UL
#define IPMSG_NOLOGOPT			0x00020000UL
#define IPMSG_NOADDLISTOPT		0x00080000UL
#define IPMSG_READCHECKOPT		0x00100000UL
#define IPMSG_SECRETEXOPT		(IPMSG_READCHECKOPT|IPMSG_SECRETOPT)

/*  obsolete option for send command  */
#define IPMSG_NOPOPUPOPTOBSOLT	0x00001000UL
#define IPMSG_NEWMULTIOPTOBSOLT	0x00040000UL

/* encryption/capability flags for encrypt command */
#define IPMSG_RSA_512			0x00000001UL
#define IPMSG_RSA_1024			0x00000002UL
#define IPMSG_RSA_2048			0x00000004UL
#define IPMSG_RC2_40			0x00001000UL
#define IPMSG_BLOWFISH_128		0x00020000UL
#define IPMSG_AES_256			0x00100000UL
#define IPMSG_PACKETNO_IV		0x00800000UL
#define IPMSG_ENCODE_BASE64		0x01000000UL
#define IPMSG_SIGN_SHA1			0x20000000UL

/* compatibilty for Win beta version */
#define IPMSG_RC2_40OLD			0x00000010UL	// for beta1-4 only
#define IPMSG_RC2_128OLD		0x00000040UL	// for beta1-4 only
#define IPMSG_BLOWFISH_128OLD	0x00000400UL	// for beta1-4 only
#define IPMSG_RC2_128OBSOLETE	0x00004000UL
#define IPMSG_RC2_256OBSOLETE	0x00008000UL
#define IPMSG_BLOWFISH_256OBSOL	0x00040000UL
#define IPMSG_AES_128OBSOLETE	0x00080000UL
#define IPMSG_SIGN_MD5OBSOLETE	0x10000000UL
#define IPMSG_UNAMEEXTOPTOBSOLT	0x02000000UL

/* file types for fileattach command */
#define IPMSG_FILE_REGULAR		0x00000001UL
#define IPMSG_FILE_DIR			0x00000002UL
#define IPMSG_FILE_RETPARENT	0x00000003UL	// return parent directory
#define IPMSG_FILE_SYMLINK		0x00000004UL
#define IPMSG_FILE_CDEV			0x00000005UL	// for UNIX
#define IPMSG_FILE_BDEV			0x00000006UL	// for UNIX
#define IPMSG_FILE_FIFO			0x00000007UL	// for UNIX
#define IPMSG_FILE_RESFORK		0x00000010UL	// for Mac
#define IPMSG_FILE_CLIPBOARD	0x00000020UL	// for Windows Clipboard

/* file attribute options for fileattach command */
#define IPMSG_FILE_RONLYOPT		0x00000100UL
#define IPMSG_FILE_HIDDENOPT	0x00001000UL
#define IPMSG_FILE_EXHIDDENOPT	0x00002000UL	// for MacOS X
#define IPMSG_FILE_ARCHIVEOPT	0x00004000UL
#define IPMSG_FILE_SYSTEMOPT	0x00008000UL

/* extend attribute types for fileattach command */
#define IPMSG_FILE_UID			0x00000001UL
#define IPMSG_FILE_USERNAME		0x00000002UL	// uid by string
#define IPMSG_FILE_GID			0x00000003UL
#define IPMSG_FILE_GROUPNAME	0x00000004UL	// gid by string
#define IPMSG_FILE_CLIPBOARDPOS	0x00000008UL	//
#define IPMSG_FILE_PERM			0x00000010UL	// for UNIX
#define IPMSG_FILE_MAJORNO		0x00000011UL	// for UNIX devfile
#define IPMSG_FILE_MINORNO		0x00000012UL	// for UNIX devfile
#define IPMSG_FILE_CTIME		0x00000013UL	// for UNIX
#define IPMSG_FILE_MTIME		0x00000014UL
#define IPMSG_FILE_ATIME		0x00000015UL
#define IPMSG_FILE_CREATETIME	0x00000016UL
#define IPMSG_FILE_CREATOR		0x00000020UL	// for Mac
#define IPMSG_FILE_FILETYPE		0x00000021UL	// for Mac
#define IPMSG_FILE_FINDERINFO	0x00000022UL	// for Mac
#define IPMSG_FILE_ACL			0x00000030UL
#define IPMSG_FILE_ALIASFNAME	0x00000040UL	// alias fname

#define FILELIST_SEPARATOR	'\a'
#define HOSTLIST_SEPARATOR	'\a'
#define HOSTLIST_DUMMY		"\b"


/*  end of IP Messenger Communication Protocol version 3.0 define  */

/*============================================================================*
 * IP Messenger for Mac OS X 定数定義
 *============================================================================*/

#define MESSAGE_SEPARATOR	":"
#define MESSAGE_MULTIPK_SEPARATOR "|"
#define MESSAGE_FEIQEXT_SEPARATOR "#"
//#define MAX_SOCKBUF			32768
#define MAX_SOCKBUF			4276800
#define RCV_SOCKBUF			32768


