--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: auth_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);


ALTER TABLE public.auth_group OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_id_seq OWNER TO postgres;

--
-- Name: auth_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_id_seq OWNED BY public.auth_group.id;


--
-- Name: auth_group_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_group_permissions (
    id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_group_permissions OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_group_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_group_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_group_permissions_id_seq OWNED BY public.auth_group_permissions.id;


--
-- Name: auth_permission; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);


ALTER TABLE public.auth_permission OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_permission_id_seq OWNER TO postgres;

--
-- Name: auth_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_permission_id_seq OWNED BY public.auth_permission.id;


--
-- Name: auth_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);


ALTER TABLE public.auth_user OWNER TO postgres;

--
-- Name: auth_user_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_groups (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.auth_user_groups OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_groups_id_seq OWNER TO postgres;

--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_groups_id_seq OWNED BY public.auth_user_groups.id;


--
-- Name: auth_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_id_seq OWNER TO postgres;

--
-- Name: auth_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_id_seq OWNED BY public.auth_user.id;


--
-- Name: auth_user_user_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_user_user_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.auth_user_user_permissions OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_user_user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_user_user_permissions_id_seq OWNER TO postgres;

--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_user_user_permissions_id_seq OWNED BY public.auth_user_user_permissions.id;


--
-- Name: blogApp_blogpost; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."blogApp_blogpost" (
    id integer NOT NULL,
    slug character varying(100) NOT NULL,
    title character varying(100) NOT NULL,
    banner_original character varying(100) NOT NULL,
    content text NOT NULL,
    draft boolean NOT NULL,
    posted timestamp with time zone NOT NULL,
    last_edited timestamp with time zone NOT NULL,
    author_id integer NOT NULL
);


ALTER TABLE public."blogApp_blogpost" OWNER TO postgres;

--
-- Name: blogApp_blogpost_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."blogApp_blogpost_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."blogApp_blogpost_id_seq" OWNER TO postgres;

--
-- Name: blogApp_blogpost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."blogApp_blogpost_id_seq" OWNED BY public."blogApp_blogpost".id;


--
-- Name: commonApp_userimage; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."commonApp_userimage" (
    id integer NOT NULL,
    object_id integer NOT NULL,
    identifier character varying(100) NOT NULL,
    alt character varying(250) NOT NULL,
    attribution character varying(250) NOT NULL,
    notes character varying(250) NOT NULL,
    image_original character varying(100) NOT NULL,
    content_type_id integer NOT NULL,
    CONSTRAINT "commonApp_userimage_object_id_check" CHECK ((object_id >= 0))
);


ALTER TABLE public."commonApp_userimage" OWNER TO postgres;

--
-- Name: commonApp_userimage_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."commonApp_userimage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."commonApp_userimage_id_seq" OWNER TO postgres;

--
-- Name: commonApp_userimage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."commonApp_userimage_id_seq" OWNED BY public."commonApp_userimage".id;


--
-- Name: dashboard_userdashboardmodule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dashboard_userdashboardmodule (
    id integer NOT NULL,
    title character varying(255) NOT NULL,
    module character varying(255) NOT NULL,
    app_label character varying(255),
    "user" integer NOT NULL,
    "column" integer NOT NULL,
    "order" integer NOT NULL,
    settings text NOT NULL,
    children text NOT NULL,
    collapsed boolean NOT NULL,
    CONSTRAINT dashboard_userdashboardmodule_column_check CHECK (("column" >= 0)),
    CONSTRAINT dashboard_userdashboardmodule_user_check CHECK (("user" >= 0))
);


ALTER TABLE public.dashboard_userdashboardmodule OWNER TO postgres;

--
-- Name: dashboard_userdashboardmodule_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.dashboard_userdashboardmodule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dashboard_userdashboardmodule_id_seq OWNER TO postgres;

--
-- Name: dashboard_userdashboardmodule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.dashboard_userdashboardmodule_id_seq OWNED BY public.dashboard_userdashboardmodule.id;


--
-- Name: django_admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);


ALTER TABLE public.django_admin_log OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_admin_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_admin_log_id_seq OWNER TO postgres;

--
-- Name: django_admin_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_admin_log_id_seq OWNED BY public.django_admin_log.id;


--
-- Name: django_content_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);


ALTER TABLE public.django_content_type OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_content_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_content_type_id_seq OWNER TO postgres;

--
-- Name: django_content_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_content_type_id_seq OWNED BY public.django_content_type.id;


--
-- Name: django_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_migrations (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);


ALTER TABLE public.django_migrations OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.django_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.django_migrations_id_seq OWNER TO postgres;

--
-- Name: django_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.django_migrations_id_seq OWNED BY public.django_migrations.id;


--
-- Name: django_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);


ALTER TABLE public.django_session OWNER TO postgres;

--
-- Name: jet_bookmark; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jet_bookmark (
    id integer NOT NULL,
    url character varying(200) NOT NULL,
    title character varying(255) NOT NULL,
    "user" integer NOT NULL,
    date_add timestamp with time zone NOT NULL,
    CONSTRAINT jet_bookmark_user_check CHECK (("user" >= 0))
);


ALTER TABLE public.jet_bookmark OWNER TO postgres;

--
-- Name: jet_bookmark_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jet_bookmark_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jet_bookmark_id_seq OWNER TO postgres;

--
-- Name: jet_bookmark_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jet_bookmark_id_seq OWNED BY public.jet_bookmark.id;


--
-- Name: jet_pinnedapplication; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jet_pinnedapplication (
    id integer NOT NULL,
    app_label character varying(255) NOT NULL,
    "user" integer NOT NULL,
    date_add timestamp with time zone NOT NULL,
    CONSTRAINT jet_pinnedapplication_user_check CHECK (("user" >= 0))
);


ALTER TABLE public.jet_pinnedapplication OWNER TO postgres;

--
-- Name: jet_pinnedapplication_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jet_pinnedapplication_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jet_pinnedapplication_id_seq OWNER TO postgres;

--
-- Name: jet_pinnedapplication_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jet_pinnedapplication_id_seq OWNED BY public.jet_pinnedapplication.id;


--
-- Name: projectsApp_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."projectsApp_category" (
    id integer NOT NULL,
    slug character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    "order" integer NOT NULL
);


ALTER TABLE public."projectsApp_category" OWNER TO postgres;

--
-- Name: projectsApp_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."projectsApp_category_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."projectsApp_category_id_seq" OWNER TO postgres;

--
-- Name: projectsApp_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."projectsApp_category_id_seq" OWNED BY public."projectsApp_category".id;


--
-- Name: projectsApp_page; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."projectsApp_page" (
    id integer NOT NULL,
    number integer NOT NULL,
    type character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    banner_original character varying(100) NOT NULL,
    thumbnail_original character varying(100) NOT NULL,
    description text NOT NULL,
    content text NOT NULL,
    draft boolean NOT NULL,
    posted timestamp with time zone NOT NULL,
    last_edited timestamp with time zone NOT NULL,
    project_id integer NOT NULL,
    CONSTRAINT "projectsApp_page_number_check" CHECK ((number >= 0))
);


ALTER TABLE public."projectsApp_page" OWNER TO postgres;

--
-- Name: projectsApp_page_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."projectsApp_page_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."projectsApp_page_id_seq" OWNER TO postgres;

--
-- Name: projectsApp_page_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."projectsApp_page_id_seq" OWNED BY public."projectsApp_page".id;


--
-- Name: projectsApp_project; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."projectsApp_project" (
    id integer NOT NULL,
    slug character varying(100) NOT NULL,
    name character varying(100) NOT NULL,
    banner_original character varying(100) NOT NULL,
    thumbnail_original character varying(100) NOT NULL,
    description text NOT NULL,
    content text NOT NULL,
    draft boolean NOT NULL,
    highlight boolean NOT NULL,
    posted timestamp with time zone NOT NULL,
    base_last_edited timestamp with time zone NOT NULL,
    notes text NOT NULL,
    author_id integer NOT NULL,
    category_id integer NOT NULL
);


ALTER TABLE public."projectsApp_project" OWNER TO postgres;

--
-- Name: projectsApp_project_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."projectsApp_project_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."projectsApp_project_id_seq" OWNER TO postgres;

--
-- Name: projectsApp_project_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."projectsApp_project_id_seq" OWNED BY public."projectsApp_project".id;


--
-- Name: taggit_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taggit_tag (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL
);


ALTER TABLE public.taggit_tag OWNER TO postgres;

--
-- Name: taggit_tag_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taggit_tag_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taggit_tag_id_seq OWNER TO postgres;

--
-- Name: taggit_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taggit_tag_id_seq OWNED BY public.taggit_tag.id;


--
-- Name: taggit_taggeditem; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taggit_taggeditem (
    id integer NOT NULL,
    object_id integer NOT NULL,
    content_type_id integer NOT NULL,
    tag_id integer NOT NULL
);


ALTER TABLE public.taggit_taggeditem OWNER TO postgres;

--
-- Name: taggit_taggeditem_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taggit_taggeditem_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.taggit_taggeditem_id_seq OWNER TO postgres;

--
-- Name: taggit_taggeditem_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taggit_taggeditem_id_seq OWNED BY public.taggit_taggeditem.id;


--
-- Name: auth_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group ALTER COLUMN id SET DEFAULT nextval('public.auth_group_id_seq'::regclass);


--
-- Name: auth_group_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_group_permissions_id_seq'::regclass);


--
-- Name: auth_permission id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission ALTER COLUMN id SET DEFAULT nextval('public.auth_permission_id_seq'::regclass);


--
-- Name: auth_user id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user ALTER COLUMN id SET DEFAULT nextval('public.auth_user_id_seq'::regclass);


--
-- Name: auth_user_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups ALTER COLUMN id SET DEFAULT nextval('public.auth_user_groups_id_seq'::regclass);


--
-- Name: auth_user_user_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions ALTER COLUMN id SET DEFAULT nextval('public.auth_user_user_permissions_id_seq'::regclass);


--
-- Name: blogApp_blogpost id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."blogApp_blogpost" ALTER COLUMN id SET DEFAULT nextval('public."blogApp_blogpost_id_seq"'::regclass);


--
-- Name: commonApp_userimage id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."commonApp_userimage" ALTER COLUMN id SET DEFAULT nextval('public."commonApp_userimage_id_seq"'::regclass);


--
-- Name: dashboard_userdashboardmodule id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_userdashboardmodule ALTER COLUMN id SET DEFAULT nextval('public.dashboard_userdashboardmodule_id_seq'::regclass);


--
-- Name: django_admin_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log ALTER COLUMN id SET DEFAULT nextval('public.django_admin_log_id_seq'::regclass);


--
-- Name: django_content_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type ALTER COLUMN id SET DEFAULT nextval('public.django_content_type_id_seq'::regclass);


--
-- Name: django_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations ALTER COLUMN id SET DEFAULT nextval('public.django_migrations_id_seq'::regclass);


--
-- Name: jet_bookmark id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jet_bookmark ALTER COLUMN id SET DEFAULT nextval('public.jet_bookmark_id_seq'::regclass);


--
-- Name: jet_pinnedapplication id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jet_pinnedapplication ALTER COLUMN id SET DEFAULT nextval('public.jet_pinnedapplication_id_seq'::regclass);


--
-- Name: projectsApp_category id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_category" ALTER COLUMN id SET DEFAULT nextval('public."projectsApp_category_id_seq"'::regclass);


--
-- Name: projectsApp_page id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_page" ALTER COLUMN id SET DEFAULT nextval('public."projectsApp_page_id_seq"'::regclass);


--
-- Name: projectsApp_project id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_project" ALTER COLUMN id SET DEFAULT nextval('public."projectsApp_project_id_seq"'::regclass);


--
-- Name: taggit_tag id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_tag ALTER COLUMN id SET DEFAULT nextval('public.taggit_tag_id_seq'::regclass);


--
-- Name: taggit_taggeditem id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_taggeditem ALTER COLUMN id SET DEFAULT nextval('public.taggit_taggeditem_id_seq'::regclass);


--
-- Data for Name: auth_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group (id, name) FROM stdin;
\.


--
-- Data for Name: auth_group_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
\.


--
-- Data for Name: auth_permission; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
1	Can add user dashboard module	1	add_userdashboardmodule
2	Can change user dashboard module	1	change_userdashboardmodule
3	Can delete user dashboard module	1	delete_userdashboardmodule
4	Can view user dashboard module	1	view_userdashboardmodule
5	Can add bookmark	2	add_bookmark
6	Can change bookmark	2	change_bookmark
7	Can delete bookmark	2	delete_bookmark
8	Can view bookmark	2	view_bookmark
9	Can add pinned application	3	add_pinnedapplication
10	Can change pinned application	3	change_pinnedapplication
11	Can delete pinned application	3	delete_pinnedapplication
12	Can view pinned application	3	view_pinnedapplication
13	Can add log entry	4	add_logentry
14	Can change log entry	4	change_logentry
15	Can delete log entry	4	delete_logentry
16	Can view log entry	4	view_logentry
17	Can add permission	5	add_permission
18	Can change permission	5	change_permission
19	Can delete permission	5	delete_permission
20	Can view permission	5	view_permission
21	Can add group	6	add_group
22	Can change group	6	change_group
23	Can delete group	6	delete_group
24	Can view group	6	view_group
25	Can add user	7	add_user
26	Can change user	7	change_user
27	Can delete user	7	delete_user
28	Can view user	7	view_user
29	Can add content type	8	add_contenttype
30	Can change content type	8	change_contenttype
31	Can delete content type	8	delete_contenttype
32	Can view content type	8	view_contenttype
33	Can add session	9	add_session
34	Can change session	9	change_session
35	Can delete session	9	delete_session
36	Can view session	9	view_session
37	Can add user image	10	add_userimage
38	Can change user image	10	change_userimage
39	Can delete user image	10	delete_userimage
40	Can view user image	10	view_userimage
41	Can add category	11	add_category
42	Can change category	11	change_category
43	Can delete category	11	delete_category
44	Can view category	11	view_category
45	Can add project	12	add_project
46	Can change project	12	change_project
47	Can delete project	12	delete_project
48	Can view project	12	view_project
49	Can add project page	13	add_page
50	Can change project page	13	change_page
51	Can delete project page	13	delete_page
52	Can view project page	13	view_page
53	Can add post	14	add_blogpost
54	Can change post	14	change_blogpost
55	Can delete post	14	delete_blogpost
56	Can view post	14	view_blogpost
57	Can add tag	15	add_tag
58	Can change tag	15	change_tag
59	Can delete tag	15	delete_tag
60	Can view tag	15	view_tag
61	Can add tagged item	16	add_taggeditem
62	Can change tagged item	16	change_taggeditem
63	Can delete tagged item	16	delete_taggeditem
64	Can view tagged item	16	view_taggeditem
\.


--
-- Data for Name: auth_user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
1	pbkdf2_sha256$320000$7hdtDGhUy9ktKdY9Tbd9mK$n4xnFN5rVB7UqoQjUW60VamwC0yalGizOpjBXp4qWSs=	2023-06-18 15:27:50+00	t	Marcelotsvaz	Marcelo	Vaz	marcelotsvaz@gmail.com	t	t	2023-06-18 15:27:42+00
\.


--
-- Data for Name: auth_user_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
\.


--
-- Data for Name: auth_user_user_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
\.


--
-- Data for Name: blogApp_blogpost; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."blogApp_blogpost" (id, slug, title, banner_original, content, draft, posted, last_edited, author_id) FROM stdin;
3	test-post-3	Test Post 3	blog/test-post-3/banner-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin rutrum diam ac massa posuere, eget accumsan turpis lobortis. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Cras dignissim interdum tincidunt. Morbi id enim in nunc facilisis mollis sed in enim. Maecenas nec lacinia lorem. Fusce luctus quam ut lorem dignissim, quis fringilla ipsum sagittis. Sed ullamcorper fringilla elit eu scelerisque. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Sed tempor ultricies ligula eget tristique. Sed lacinia egestas nunc, eu faucibus eros facilisis et. Aenean ut diam nec urna finibus euismod vel ut velit. In ultrices luctus fermentum.\n\n<!--break-->\n\nPellentesque a finibus dui. Sed leo mauris, imperdiet vitae cursus et, ornare non magna. Integer faucibus interdum blandit. Ut massa neque, porta in arcu a, gravida porttitor odio. Maecenas nec turpis non augue aliquam convallis eu nec arcu. Vivamus fermentum malesuada orci eget maximus. Nullam suscipit turpis nunc. Nulla facilisi. Maecenas vitae egestas sem. Suspendisse viverra nibh accumsan urna ornare, a egestas sapien commodo. Pellentesque velit velit, molestie at nunc ut, semper laoreet ipsum. Quisque sit amet feugiat dui. Vestibulum placerat luctus congue. Ut magna massa, semper vel congue a, pharetra eu felis. Suspendisse ac dictum odio, blandit vestibulum ante. Proin hendrerit nunc sit amet consequat mollis.\n\nAliquam finibus lobortis libero, eget mattis mauris. Quisque eget leo est. Duis leo neque, rutrum pretium nisi tempor, mollis imperdiet mi. Cras vitae lectus at nibh aliquet convallis. Curabitur quis nisi et erat pretium accumsan. Fusce ac sodales nibh. Sed vehicula fringilla quam, vel consectetur felis. Donec vel congue lacus.	f	2023-06-18 15:30:57.684402+00	2023-06-18 16:14:43.635531+00	1
2	test-post-2	Test Post 2	blog/test-post-2/banner-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla accumsan vitae orci finibus sollicitudin. Fusce eros tellus, imperdiet in erat et, maximus euismod felis. Praesent vitae magna eu velit accumsan vestibulum eu a nibh. Vivamus venenatis elit quis felis maximus, molestie eleifend felis convallis. Curabitur in aliquam ipsum. Vivamus bibendum, risus ut vulputate lobortis, arcu felis sollicitudin sapien, a dictum turpis elit pretium nunc. Sed dolor leo, elementum vitae nisi varius, lacinia bibendum nisi. Cras efficitur commodo lacus eget vehicula. Curabitur sagittis sapien sit amet lorem hendrerit aliquet. Proin maximus eu urna eu pellentesque. Nam egestas tellus massa, in posuere est aliquam ac. Aliquam et lectus ut purus auctor varius vitae quis tellus.\n\n<!--break-->\n\nVestibulum convallis eros vitae justo ullamcorper gravida. Sed ac semper ligula. Aliquam et libero non dolor interdum posuere. Aenean consequat cursus ornare. Nullam ultrices odio nulla, at tempor dui pharetra non. Vestibulum quis velit iaculis erat semper condimentum eget nec augue. Duis sed rutrum purus, quis bibendum nisl. Nam purus purus, faucibus viverra enim vulputate, iaculis vestibulum elit. Donec eu luctus justo, vitae sollicitudin purus. Mauris dolor massa, consectetur quis justo non, aliquam porta metus. Quisque in purus nec augue scelerisque varius at at leo. Suspendisse non nisi faucibus, pulvinar nibh sed, tincidunt nunc.\n\nDuis turpis quam, interdum at vehicula vitae, hendrerit eget mauris. Integer at elementum urna. Phasellus elit libero, posuere a magna in, viverra ullamcorper risus. Maecenas egestas purus sit amet ligula vehicula, ut tristique diam tristique. Vestibulum auctor nibh vitae erat dignissim venenatis. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec interdum commodo eros eget lobortis. Aliquam ipsum magna, fermentum ac viverra vel, convallis a ante. Aliquam tincidunt ante at metus dictum sodales. Nullam vel orci mollis, tempus erat vitae, finibus urna. In suscipit elit vel velit tincidunt, vitae viverra lorem accumsan. Suspendisse risus orci, gravida quis tellus in, congue imperdiet libero. Mauris luctus velit turpis, eget vulputate purus mollis vel. Sed eu orci luctus, laoreet dolor et, porta tortor.	f	2023-06-18 15:30:57.929425+00	2023-06-18 16:14:40.384166+00	1
4	test-post-4	Test Post 4	blog/test-post-4/banner-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent mattis molestie vulputate. Duis lobortis diam turpis, in laoreet ante convallis ac. Praesent leo enim, commodo ut dapibus ac, aliquam quis metus. Fusce ac leo tincidunt, laoreet ante id, malesuada dui. Aliquam eu cursus libero. Duis malesuada ante eget mauris cursus sagittis eget et est. Sed ex neque, mattis scelerisque ultrices eget, placerat sit amet tortor. Praesent sed tristique felis. Pellentesque eleifend urna orci, finibus pretium diam convallis a. Phasellus nec metus ut nisi interdum viverra eget nec leo. Donec egestas hendrerit metus eu tempus. Fusce placerat nibh id nisi auctor consequat.\n\n<!--break-->\n\nProin bibendum consectetur sapien, in iaculis nunc dictum eget. Vestibulum massa sapien, tempor in dictum nec, blandit quis enim. Fusce tincidunt a nunc vitae volutpat. Ut maximus velit vitae pulvinar eleifend. Fusce auctor, mi id convallis pretium, nisl erat sagittis massa, vitae volutpat urna mi ac arcu. Nulla sem erat, fringilla in luctus vitae, fringilla quis felis. Pellentesque massa nulla, ullamcorper eu venenatis eget, aliquet a lorem.\n\nPhasellus gravida leo sit amet tincidunt tincidunt. Donec tincidunt fermentum odio, non venenatis enim pretium in. Vivamus dictum efficitur volutpat. Sed consequat placerat congue. Curabitur ac imperdiet urna, vel tincidunt ante. Etiam viverra rutrum erat. Integer nec neque gravida magna interdum maximus. Aliquam congue risus tempus, dignissim augue ac, laoreet est. Vivamus tellus elit, convallis sed tincidunt non, iaculis ac odio. Mauris a vestibulum turpis.	f	2023-06-18 15:30:57.435807+00	2023-06-18 16:15:15.679444+00	1
5	test-post-5-unpublished	Test Post 5 (Unpublished)	blog/test-post-5-unpublished/banner-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus eleifend aliquet bibendum. Pellentesque quis sodales metus, nec suscipit ex. Donec vitae tortor iaculis, semper mauris in, feugiat enim. Sed quis fringilla risus, vitae blandit ipsum. Nullam ac mi pharetra, fringilla urna egestas, suscipit massa. Cras in auctor urna. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla quis finibus ipsum. Fusce eget sagittis quam. Nam vitae nulla ipsum.\n\n<!--break-->\n\nCras erat purus, dapibus in nibh sit amet, hendrerit varius nisl. Aliquam at massa ante. Maecenas ex orci, lacinia eget elementum eu, rutrum et odio. Duis quis massa semper, aliquam diam aliquet, venenatis nibh. Vestibulum eu varius ipsum. Suspendisse pellentesque suscipit metus. Nullam vitae eros sagittis, laoreet elit quis, sagittis nisl. Praesent dictum justo a dui fringilla, id hendrerit sapien tempor. Fusce sed varius ante, in laoreet nunc.\n\nSuspendisse et volutpat tellus. Donec ut condimentum tortor, eu vulputate mi. Vestibulum malesuada dui condimentum, lobortis tortor eget, mattis dui. In vehicula quam elit, eu fringilla leo mollis sed. Maecenas blandit, dolor id placerat ornare, turpis odio convallis diam, ut porta eros arcu et justo. Praesent venenatis tortor metus, sit amet aliquam ex vestibulum non. Etiam imperdiet dolor quis turpis ullamcorper ultricies. Donec rhoncus malesuada justo, eget convallis diam suscipit iaculis. Sed luctus orci metus, eget consequat ipsum fermentum eget. In posuere accumsan massa sed facilisis. Sed mauris nibh, sollicitudin eget tincidunt id, volutpat sed nunc.	t	2023-06-18 15:30:50.718648+00	2023-06-18 17:50:53.412335+00	1
1	test-post-1	Test Post 1	blog/test-post-1/banner-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque sit amet nisl vehicula, faucibus risus ac, mollis mauris. Maecenas imperdiet quis ante ac rutrum. Mauris semper ornare aliquam. Phasellus dictum metus justo, hendrerit posuere magna maximus nec. Aenean iaculis, velit ac interdum sagittis, nisl ante mollis dui, sagittis dignissim libero elit sed dui. Vivamus nec neque interdum, lobortis ante id, condimentum ligula. Maecenas arcu ante, blandit in elit ut, malesuada auctor tortor. Proin laoreet mi ut sem congue volutpat in sed nisl. Phasellus tincidunt lacus nisi, in elementum augue viverra et. Nullam leo nulla, vehicula eget magna vitae, consequat aliquet sapien. Morbi id congue urna. Suspendisse pretium aliquam consectetur. Morbi hendrerit lacus et ex cursus iaculis vitae vel nisi.\n\n<!--break-->\n\nPellentesque eget gravida neque. Cras nec elit lectus. Donec consectetur dui et mollis consectetur. Sed at justo faucibus, volutpat enim at, fermentum mi. Nullam dignissim sit amet dolor eu viverra. Etiam dapibus ante ut nulla dapibus tincidunt. Aliquam vel sollicitudin odio. Praesent in lacus ut lectus maximus auctor quis non purus. Nam sit amet enim tempor, ullamcorper mauris a, ullamcorper diam. Morbi quis nisi arcu. Cras porta at mi vel porttitor. Nunc et mattis diam. Donec posuere enim id egestas bibendum. Pellentesque vel lectus sodales, accumsan massa ut, facilisis dolor. Vivamus vestibulum orci enim, sed finibus elit dapibus ac.\n\n#[](user-image-1, user-image-2, user-image-3)\n\nIn euismod, augue et consectetur aliquam, orci mauris ultrices nunc, at vehicula felis risus vitae sem. In egestas lobortis nisl, vitae volutpat enim tempor sed. Cras lacus arcu, dapibus ultricies massa varius, feugiat tristique odio. Vivamus bibendum ac erat a vehicula. Maecenas hendrerit elit sodales ante consectetur, nec aliquam lectus pretium. Vestibulum semper ut tellus sed fermentum. Maecenas vulputate ultrices mauris sed auctor. Ut tempus ipsum turpis, ut vehicula nisi luctus quis. Integer ac tortor a diam vestibulum facilisis id at nunc. Interdum et malesuada fames ac ante ipsum primis in faucibus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam non euismod libero. Nulla sit amet interdum erat. Proin neque augue, porta tempor auctor id, faucibus convallis ex. Interdum et malesuada fames ac ante ipsum primis in faucibus. Praesent aliquam quis lectus eu lacinia.	f	2023-06-18 15:30:58.165397+00	2023-06-18 17:30:19.719014+00	1
\.


--
-- Data for Name: commonApp_userimage; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."commonApp_userimage" (id, object_id, identifier, alt, attribution, notes, image_original, content_type_id) FROM stdin;
4	1	user-image-1	User image 1 description.			blog/test-post-1/user-image-1-original.webp	14
5	1	user-image-2	User image 2 description.			blog/test-post-1/user-image-2-original.webp	14
6	1	user-image-3	User image 3 description.			blog/test-post-1/user-image-3-original.webp	14
7	1	user-image-1	User image 1 description.			projects/test-project-1/user-image-1-original.webp	12
8	1	user-image-2	User image 2 description.			projects/test-project-1/user-image-2-original.webp	12
9	1	user-image-3	User image 3 description.			projects/test-project-1/user-image-3-original.webp	12
10	1	user-image-4	User image 4 description.			projects/test-project-1/user-image-4-original.webp	12
11	1	user-image-5	User image 5 description.			projects/test-project-1/user-image-5-original.webp	12
\.


--
-- Data for Name: dashboard_userdashboardmodule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dashboard_userdashboardmodule (id, title, module, app_label, "user", "column", "order", settings, children, collapsed) FROM stdin;
1	Quick links	jet.dashboard.modules.LinkList	\N	1	0	0	{"draggable": false, "deletable": false, "collapsible": false, "layout": "inline"}	[{"title": "Return to site", "url": "/"}, {"title": "Change password", "url": "/admin/password_change/"}, {"title": "Log out", "url": "/admin/logout/"}]	f
2	Applications	jet.dashboard.modules.AppList	\N	1	1	0	{"models": null, "exclude": ["auth.*"]}		f
3	Administration	jet.dashboard.modules.AppList	\N	1	2	0	{"models": ["auth.*"], "exclude": null}		f
4	Recent Actions	jet.dashboard.modules.RecentActions	\N	1	0	1	{"limit": 10, "include_list": null, "exclude_list": null, "user": null}		f
5	Latest Django News	jet.dashboard.modules.Feed	\N	1	1	1	{"feed_url": "http://www.djangoproject.com/rss/weblog/", "limit": 5}		f
6	Support	jet.dashboard.modules.LinkList	\N	1	2	1	{"draggable": true, "deletable": true, "collapsible": true, "layout": "stacked"}	[{"title": "Django documentation", "url": "http://docs.djangoproject.com/", "external": true}, {"title": "Django \\"django-users\\" mailing list", "url": "http://groups.google.com/group/django-users", "external": true}, {"title": "Django irc channel", "url": "irc://irc.freenode.net/django", "external": true}]	f
\.


--
-- Data for Name: django_admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
\.


--
-- Data for Name: django_content_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_content_type (id, app_label, model) FROM stdin;
1	dashboard	userdashboardmodule
2	jet	bookmark
3	jet	pinnedapplication
4	admin	logentry
5	auth	permission
6	auth	group
7	auth	user
8	contenttypes	contenttype
9	sessions	session
10	commonApp	userimage
11	projectsApp	category
12	projectsApp	project
13	projectsApp	page
14	blogApp	blogpost
15	taggit	tag
16	taggit	taggeditem
\.


--
-- Data for Name: django_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_migrations (id, app, name, applied) FROM stdin;
1	contenttypes	0001_initial	2023-06-18 15:26:37.509152+00
2	auth	0001_initial	2023-06-18 15:26:37.655238+00
3	admin	0001_initial	2023-06-18 15:26:37.708601+00
4	admin	0002_logentry_remove_auto_add	2023-06-18 15:26:37.723353+00
5	admin	0003_logentry_add_action_flag_choices	2023-06-18 15:26:37.73806+00
6	contenttypes	0002_remove_content_type_name	2023-06-18 15:26:37.756664+00
7	auth	0002_alter_permission_name_max_length	2023-06-18 15:26:37.766195+00
8	auth	0003_alter_user_email_max_length	2023-06-18 15:26:37.781218+00
9	auth	0004_alter_user_username_opts	2023-06-18 15:26:37.817973+00
10	auth	0005_alter_user_last_login_null	2023-06-18 15:26:37.826363+00
11	auth	0006_require_contenttypes_0002	2023-06-18 15:26:37.830303+00
12	auth	0007_alter_validators_add_error_messages	2023-06-18 15:26:37.838168+00
13	auth	0008_alter_user_username_max_length	2023-06-18 15:26:37.857996+00
14	auth	0009_alter_user_last_name_max_length	2023-06-18 15:26:37.867716+00
15	auth	0010_alter_group_name_max_length	2023-06-18 15:26:37.878278+00
16	auth	0011_update_proxy_permissions	2023-06-18 15:26:37.886634+00
17	auth	0012_alter_user_first_name_max_length	2023-06-18 15:26:37.896814+00
18	taggit	0001_initial	2023-06-18 15:26:37.947638+00
19	taggit	0002_auto_20150616_2121	2023-06-18 15:26:37.957392+00
20	taggit	0003_taggeditem_add_unique_index	2023-06-18 15:26:37.967021+00
21	taggit	0004_alter_taggeditem_content_type_alter_taggeditem_tag	2023-06-18 15:26:37.98545+00
22	blogApp	0001_initial	2023-06-18 15:26:38.020321+00
23	blogApp	0002_alter_blogpost_tags	2023-06-18 15:26:38.031329+00
24	commonApp	0001_initial	2023-06-18 15:26:38.085854+00
25	dashboard	0001_initial	2023-06-18 15:26:38.100313+00
26	jet	0001_initial	2023-06-18 15:26:38.133257+00
27	jet	0002_delete_userdashboardmodule	2023-06-18 15:26:38.140397+00
28	projectsApp	0001_initial	2023-06-18 15:26:38.252345+00
29	sessions	0001_initial	2023-06-18 15:26:38.285449+00
30	taggit	0005_auto_20220424_2025	2023-06-18 15:26:38.297866+00
\.


--
-- Data for Name: django_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
\.


--
-- Data for Name: jet_bookmark; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jet_bookmark (id, url, title, "user", date_add) FROM stdin;
\.


--
-- Data for Name: jet_pinnedapplication; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jet_pinnedapplication (id, app_label, "user", date_add) FROM stdin;
\.


--
-- Data for Name: projectsApp_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."projectsApp_category" (id, slug, name, "order") FROM stdin;
1	test-category-1	Test Category 1	0
2	test-category-2	Test Category 2	0
3	test-category-3	Test Category 3	0
\.


--
-- Data for Name: projectsApp_page; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."projectsApp_page" (id, number, type, name, banner_original, thumbnail_original, description, content, draft, posted, last_edited, project_id) FROM stdin;
1	1		Page 1	projects/test-project-1/page/1/banner-original.webp	projects/test-project-1/page/1/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rhoncus viverra nibh, quis rutrum eros facilisis vel. Vestibulum accumsan tortor vel tellus efficitur porttitor.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris rhoncus viverra nibh, quis rutrum eros facilisis vel. Vestibulum accumsan tortor vel tellus efficitur porttitor. Vivamus sodales vulputate enim vel feugiat. Donec sed turpis sed nisl dignissim varius. Duis vel risus lacus. Cras vitae porta tortor. Aliquam magna leo, lobortis sed iaculis quis, lacinia eget tortor. Praesent urna purus, fermentum eget consectetur a, dignissim volutpat diam.\n\n#[](user-image-4, user-image-5)\n\nMaecenas ut justo tortor. Morbi iaculis justo ut nisl mattis, sed faucibus est elementum. Maecenas iaculis rutrum leo id laoreet. In mollis sem vel tincidunt condimentum. Mauris laoreet feugiat mi, ac egestas ligula molestie vel. Proin mattis eleifend lacus, sit amet efficitur felis dapibus a. Ut eleifend odio et lectus laoreet elementum. Nunc tristique eu ante non ultrices. Proin orci erat, ornare quis blandit pretium, convallis at ante.\n\nSuspendisse ut elit at urna laoreet fringilla quis ac ex. Vestibulum quis mattis velit. Fusce rhoncus tempor sem eu hendrerit. Nunc dapibus ipsum ut sapien viverra, eget facilisis lacus lacinia. Curabitur mattis sit amet sem quis laoreet. Nullam convallis aliquet felis at rutrum. Donec at arcu venenatis, volutpat dui ac, efficitur odio. Duis a nisi placerat, consequat orci eget, fermentum metus. Aenean sit amet nisi id nisl convallis ornare. Integer hendrerit feugiat eros sed egestas. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean eget dolor ac felis congue iaculis et vitae quam. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin tortor tellus, interdum ac neque sagittis, commodo fringilla risus.	f	2023-06-18 15:52:59.153441+00	2023-06-18 20:44:20.248529+00	1
2	2		Page 2	projects/test-project-1/page/2/banner-original.webp	projects/test-project-1/page/2/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent consequat placerat accumsan. Phasellus hendrerit mi nec luctus varius.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent consequat placerat accumsan. Phasellus hendrerit mi nec luctus varius. Mauris euismod hendrerit tortor, in consequat metus ullamcorper at. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam sit amet nulla lacinia, fringilla dui in, varius justo. Morbi placerat tristique libero at dignissim. Etiam suscipit eu nulla sit amet accumsan. Donec rhoncus vehicula tortor. Aliquam vestibulum hendrerit metus at placerat. Maecenas mi odio, tincidunt et mattis eu, vestibulum quis tellus. Donec ornare viverra dolor, a rhoncus urna congue sit amet. Integer scelerisque, augue a sollicitudin gravida, eros massa interdum purus, et vulputate mi nulla in nibh.\n\nPhasellus vulputate nisi vel elit porta, id vulputate urna commodo. Sed bibendum ut lectus aliquet luctus. Aliquam erat volutpat. Ut porta diam non sapien fermentum luctus. Sed a pretium tellus. Sed vehicula porttitor elit, a sollicitudin felis blandit sed. Nulla facilisi. Integer vel nisl ullamcorper, pretium lectus nec, sollicitudin quam. Integer nec nunc elementum, bibendum nisl sed, gravida ipsum. Nullam elit nulla, rutrum ac eleifend vitae, posuere at nulla. Vestibulum rhoncus enim a pulvinar aliquam. Quisque semper ligula in diam vestibulum vehicula. Phasellus vestibulum ligula urna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Integer aliquam consectetur libero eget pretium.\n\nIn vel nibh sed mauris convallis porta. Duis justo dui, porttitor vel commodo eu, ultrices in elit. Nam ornare a ante in fringilla. Duis condimentum volutpat libero, ac tempus turpis lacinia nec. Quisque diam magna, fermentum a lorem nec, laoreet malesuada libero. Donec suscipit leo nunc, in molestie enim scelerisque at. Duis tristique tristique eros, ac dignissim nunc interdum quis. Praesent eu lectus ac tortor consectetur ullamcorper non eu mi. Cras pharetra nec elit vitae mollis. Etiam tincidunt elit diam, vitae rutrum ex accumsan sit amet. Mauris nisi risus, gravida a semper vitae, finibus sit amet arcu. Ut in elit vitae justo gravida viverra nec ut velit.	f	2023-06-18 15:52:59.38243+00	2023-06-18 20:44:20.440519+00	1
3	3		Page 3	projects/test-project-1/page/3/banner-original.webp	projects/test-project-1/page/3/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vitae ipsum mauris. Vestibulum vitae massa orci.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce vitae ipsum mauris. Vestibulum vitae massa orci. Praesent cursus, dolor non feugiat maximus, justo quam interdum massa, finibus dictum leo ligula vitae turpis. Quisque ut tortor enim. Integer ut eros lacus. Sed ultrices turpis quam, eu posuere justo eleifend quis. Donec sed enim viverra, convallis metus ac, cursus velit. Ut fermentum, lacus at dictum mattis, mauris lacus lacinia risus, sit amet dictum augue ex a purus. Pellentesque non finibus diam.\n\nAenean quis neque tristique ante pulvinar tincidunt. Morbi et finibus odio. Integer tempor euismod nibh, at malesuada tortor tristique vel. Cras risus sapien, cursus in magna in, venenatis varius sem. Cras sapien odio, sodales in sem in, sagittis sodales massa. Phasellus eu tellus nec turpis suscipit pulvinar. Etiam mollis a mi eu porttitor. Donec dignissim semper commodo. Sed dui ligula, accumsan eget velit non, maximus aliquam risus. Praesent ut risus id mi sagittis suscipit. Sed tristique, orci suscipit blandit iaculis, arcu sem consequat magna, a rutrum justo massa sit amet est. Duis a sapien accumsan, pretium ante at, tempor turpis. Donec ac nunc ullamcorper, auctor est sit amet, rhoncus purus.\n\nMorbi et varius sapien, ac ultricies elit. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aenean sem lacus, luctus commodo vulputate vitae, facilisis sit amet diam. Sed mattis ante a consectetur tempus. Phasellus ligula est, dapibus sed consectetur nec, ornare in purus. Nulla maximus laoreet justo ac tincidunt. Mauris eu nisi dui. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Mauris eu sollicitudin neque. Vestibulum in elit eu mauris commodo efficitur quis non enim.	f	2023-06-18 15:52:59.57377+00	2023-06-18 20:44:20.617663+00	1
5	1		Page 1 (Unpublished)	projects/test-project-3-unpublished/page/1/banner-original.webp	projects/test-project-3-unpublished/page/1/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus nulla dui, scelerisque vel urna quis, congue placerat tellus. Sed ultricies consequat posuere.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus nulla dui, scelerisque vel urna quis, congue placerat tellus. Sed ultricies consequat posuere. Curabitur justo nulla, sagittis id vulputate quis, laoreet vitae lacus. Quisque rutrum tellus non arcu rhoncus ullamcorper vel a leo. Suspendisse fermentum libero vel nibh iaculis, sed sollicitudin nulla fermentum. Nam ultrices ultrices eleifend. Mauris eget bibendum lectus. Praesent ullamcorper maximus felis, vehicula commodo felis egestas ac. Aenean rhoncus lacinia odio, commodo gravida ante. Nunc congue auctor iaculis. Vivamus cursus porta pellentesque. Phasellus consequat sem rhoncus orci tincidunt, eget pretium mauris eleifend. Fusce erat tellus, sagittis eget dui ut, placerat semper lectus.\n\nDuis eros urna, efficitur at magna sed, lacinia ullamcorper velit. Ut magna felis, ullamcorper a dui non, gravida consequat dui. Donec sit amet nulla quis lectus condimentum congue. Nulla orci est, rhoncus vel vulputate vel, lobortis sed odio. Pellentesque non aliquam metus. Vivamus et lacus in odio aliquet sollicitudin. Aliquam eget nisl sapien. Suspendisse eget purus id magna porttitor posuere at id nisl. Duis eget erat purus. Quisque feugiat et erat vel faucibus.\n\nPhasellus sit amet risus velit. Maecenas metus risus, facilisis vitae sodales vestibulum, interdum ornare elit. Quisque faucibus ut quam ut venenatis. Mauris et magna pretium, ornare tellus ac, commodo leo. Nullam imperdiet rutrum velit. Maecenas lorem lorem, facilisis non orci quis, placerat consectetur lacus. Curabitur in leo ac tellus placerat tempus.	t	2023-06-18 17:46:45.147257+00	2023-06-18 20:42:12.778788+00	3
4	4		Page 4 (Unpublished)	projects/test-project-1/page/4/banner-original.webp	projects/test-project-1/page/4/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam quis orci a enim bibendum consequat. Mauris mollis ante feugiat lectus fringilla, at mattis leo venenatis.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam quis orci a enim bibendum consequat. Mauris mollis ante feugiat lectus fringilla, at mattis leo venenatis. Nam pharetra justo quis nulla placerat, non rhoncus erat tempus. Nullam congue at neque eget tristique. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Morbi eget feugiat nibh. Donec ac tincidunt orci. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Proin erat massa, auctor at tincidunt vel, consectetur iaculis nisi. Aliquam lacus justo, venenatis ac turpis ac, posuere ultrices ex. In elit purus, ultrices ut molestie sed, placerat ut lacus. Aenean fermentum purus sit amet turpis dapibus facilisis.\n\n\n#[](user-image-1, user-image-2, user-image-3, user-image-4, user-image-5)\n\nCurabitur ut interdum purus, a iaculis nisi. Phasellus ornare mattis sapien, a aliquet nibh aliquam aliquam. Proin urna sem, ornare at accumsan eget, volutpat et ipsum. Duis efficitur imperdiet odio non scelerisque. Curabitur turpis magna, porta in ipsum vitae, vulputate pharetra lorem. Duis vel dictum nisl. Curabitur dictum interdum ante, eget laoreet lectus. Nam placerat mi id varius sodales. Duis molestie massa magna, nec vestibulum lorem feugiat in. Aliquam quis vestibulum augue. Sed facilisis magna non eros ultricies rutrum. Suspendisse placerat, lacus at luctus maximus, lacus velit molestie libero, vel efficitur velit ante ac enim. Integer tristique hendrerit sollicitudin. Donec eu dignissim lectus.\n\nMorbi egestas turpis nunc, eget vulputate dolor feugiat nec. Donec consectetur id nisl nec lobortis. Cras rhoncus orci sit amet dui aliquam, in fermentum elit feugiat. Nunc nec elit augue. Morbi non ante quam. Nullam sollicitudin varius nisl vel malesuada. Quisque id neque consectetur, fermentum nunc a, facilisis elit. Vestibulum ac risus in ante ultrices tristique. Vivamus enim nibh, tristique in bibendum sed, rutrum et ante. Praesent faucibus volutpat urna, ac bibendum tortor malesuada et.	t	2023-06-18 17:36:52.407758+00	2023-06-18 20:44:20.785313+00	1
\.


--
-- Data for Name: projectsApp_project; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."projectsApp_project" (id, slug, name, banner_original, thumbnail_original, description, content, draft, highlight, posted, base_last_edited, notes, author_id, category_id) FROM stdin;
2	test-project-2-single-page	Test Project 2 (Single Page)	projects/test-project-2-single-page/banner-original.webp	projects/test-project-2-single-page/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vel ornare sapien. Nunc et tincidunt turpis.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam vel ornare sapien. Nunc et tincidunt turpis. Vivamus iaculis dignissim nibh sit amet eleifend. Curabitur aliquet varius tellus a porttitor. Sed pulvinar ornare magna ut laoreet. Praesent et erat aliquam, ultrices erat nec, posuere massa. Vivamus vehicula varius pellentesque. Mauris sagittis ullamcorper ipsum, quis tincidunt dui tempor sed. Cras hendrerit varius quam at egestas. Etiam ut lorem neque. Curabitur egestas molestie justo vitae cursus. Morbi feugiat molestie velit, ut dictum turpis. Aenean id turpis id risus tincidunt varius.\n\nMorbi vulputate iaculis lacus, quis pulvinar sem sagittis eu. Nam ac mauris leo. Mauris ultricies, ex at ultricies sagittis, diam sapien rutrum mauris, vel scelerisque sem felis vitae ante. Donec varius tellus sapien, nec ornare metus sollicitudin non. Aenean posuere libero vitae mauris sollicitudin vehicula. Sed lacus libero, interdum sit amet pulvinar eu, congue nec urna. Nullam pretium purus id nisl feugiat placerat.\n\nMaecenas ac arcu felis. Nullam sollicitudin eros in magna lacinia faucibus. Praesent quis felis metus. Sed laoreet a dolor et efficitur. Aliquam finibus elementum odio vel fermentum. Aenean pulvinar lacus massa, vel suscipit sapien fringilla nec. Donec libero dui, feugiat ac pulvinar id, hendrerit et erat. Pellentesque et turpis congue, laoreet purus non, tincidunt massa. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer turpis elit, sollicitudin eu urna vitae, efficitur lacinia magna. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Etiam eu metus cursus, vulputate erat eget, egestas orci. Vivamus tincidunt odio massa.	f	t	2023-06-18 16:10:22.034303+00	2023-06-18 20:26:53.261922+00		1	2
1	test-project-1	Test Project 1	projects/test-project-1/banner-original.webp	projects/test-project-1/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras volutpat elit vitae nibh hendrerit suscipit. In hac habitasse platea dictumst.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras volutpat elit vitae nibh hendrerit suscipit. In hac habitasse platea dictumst. Duis vulputate, lacus in aliquam sagittis, tortor mi blandit neque, sit amet eleifend ante tortor et nisi. Duis sagittis sollicitudin nulla at eleifend. Donec dapibus non ipsum at feugiat. Sed eget pulvinar risus, vitae rutrum diam. Etiam et mauris ex. Etiam commodo sem non pellentesque elementum. Phasellus sed lobortis est, et lobortis nunc. Maecenas maximus leo vel leo dictum bibendum. Vestibulum erat tortor, bibendum nec aliquam ut, molestie sit amet nibh.\n\n#[](user-image-1, user-image-2, user-image-3)\n\nMaecenas ornare arcu neque, at pulvinar orci vulputate eget. Phasellus eu eleifend augue, quis congue libero. Ut at ante scelerisque, pretium nunc quis, suscipit mauris. Integer aliquet nisl maximus, aliquam lectus eu, condimentum neque. Curabitur eu convallis est, venenatis dignissim ligula. Integer interdum consectetur mi, volutpat suscipit risus pellentesque quis. Mauris iaculis enim eu mi scelerisque posuere. Quisque eget lorem risus. Maecenas venenatis dapibus purus fringilla mattis. Morbi diam dolor, viverra ac vehicula quis, eleifend non eros.\n\nPellentesque nec tortor est. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Donec elementum magna eget rutrum finibus. Nunc molestie, elit eu porta lacinia, quam orci dapibus justo, non sodales magna magna quis quam. Nullam laoreet, justo eget posuere feugiat, orci magna finibus tortor, in laoreet lectus lectus vitae augue. Proin vitae cursus nulla. Mauris sagittis ex quis interdum feugiat. Phasellus eu sagittis dui. Etiam faucibus urna maximus nunc porttitor, vel venenatis nulla scelerisque. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla ac mattis lorem. In vulputate volutpat urna, eu hendrerit magna aliquam a. Curabitur eget tempus augue. Nunc eget ipsum id quam molestie vulputate et ut magna. Quisque non velit rhoncus, mollis mi eu, iaculis lectus.	f	t	2023-06-18 15:52:59.74799+00	2023-06-18 20:44:20.02268+00		1	1
3	test-project-3-unpublished	Test Project 3 (Unpublished)	projects/test-project-3-unpublished/banner-original.webp	projects/test-project-3-unpublished/thumbnail-original.webp	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc porta sem mattis, tristique ante tristique, mollis erat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.	Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc porta sem mattis, tristique ante tristique, mollis erat. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed scelerisque consectetur enim, et auctor elit pulvinar sit amet. Cras dignissim diam lorem, quis egestas libero mattis nec. Nam quis imperdiet odio, non sagittis ex. Nullam nec imperdiet diam. In vulputate diam id dui volutpat egestas. Cras dignissim arcu a lorem scelerisque interdum. Vestibulum egestas, nulla ut fringilla bibendum, nunc velit volutpat massa, vitae ullamcorper dolor nibh sed augue.\n\nCras suscipit vulputate erat, vitae elementum lacus accumsan ac. Mauris vestibulum, risus sed auctor rhoncus, est elit interdum arcu, in efficitur sem augue nec ante. Proin turpis leo, placerat eget purus malesuada, luctus suscipit justo. Nam non tellus a enim egestas efficitur. Sed quis sodales dolor. Nulla facilisi. Curabitur sem ante, pulvinar ut rhoncus sed, hendrerit et augue. Pellentesque varius, mi vitae condimentum accumsan, tellus nulla consequat lectus, id tempus ligula ipsum ornare ligula. Vestibulum lorem mi, placerat gravida aliquam at, porta ac eros. Fusce suscipit vestibulum erat, et blandit ligula. Donec vitae porta orci. Vestibulum a est euismod, imperdiet metus eget, aliquet nisi. Fusce convallis at turpis at tempus.\n\nEtiam a vulputate leo. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Integer eget posuere lectus, eget lobortis ante. Pellentesque finibus volutpat quam vel accumsan. Mauris vestibulum quam a mauris condimentum, quis condimentum libero fermentum. Vestibulum vehicula ipsum magna, et blandit ipsum vestibulum non. Phasellus ultrices imperdiet urna, eget imperdiet neque. Ut tempus aliquet metus, egestas tempor risus euismod id. Donec convallis commodo est vitae blandit.	t	t	2023-06-18 17:46:45.139052+00	2023-06-18 20:42:12.600757+00		1	3
\.


--
-- Data for Name: taggit_tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.taggit_tag (id, name, slug) FROM stdin;
1	Test Tag 1	test-tag-1
2	Test Tag 2	test-tag-2
3	Test Tag 3	test-tag-3
5	Test Tag 5 (Unpublished)	test-tag-5-unpublished
4	Test Tag 4 (Empty)	test-tag-4-empty
\.


--
-- Data for Name: taggit_taggeditem; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.taggit_taggeditem (id, object_id, content_type_id, tag_id) FROM stdin;
6	1	14	1
7	2	14	2
8	3	14	3
9	4	14	1
10	4	14	2
11	4	14	3
12	5	14	5
\.


--
-- Name: auth_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);


--
-- Name: auth_group_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);


--
-- Name: auth_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_permission_id_seq', 64, true);


--
-- Name: auth_user_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);


--
-- Name: auth_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_id_seq', 1, true);


--
-- Name: auth_user_user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);


--
-- Name: blogApp_blogpost_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."blogApp_blogpost_id_seq"', 5, true);


--
-- Name: commonApp_userimage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."commonApp_userimage_id_seq"', 11, true);


--
-- Name: dashboard_userdashboardmodule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.dashboard_userdashboardmodule_id_seq', 6, true);


--
-- Name: django_admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_admin_log_id_seq', 84, true);


--
-- Name: django_content_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_content_type_id_seq', 16, true);


--
-- Name: django_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.django_migrations_id_seq', 30, true);


--
-- Name: jet_bookmark_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jet_bookmark_id_seq', 1, false);


--
-- Name: jet_pinnedapplication_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jet_pinnedapplication_id_seq', 1, false);


--
-- Name: projectsApp_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."projectsApp_category_id_seq"', 3, true);


--
-- Name: projectsApp_page_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."projectsApp_page_id_seq"', 5, true);


--
-- Name: projectsApp_project_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."projectsApp_project_id_seq"', 3, true);


--
-- Name: taggit_tag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taggit_tag_id_seq', 11, true);


--
-- Name: taggit_taggeditem_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taggit_taggeditem_id_seq', 12, true);


--
-- Name: auth_group auth_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);


--
-- Name: auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);


--
-- Name: auth_group_permissions auth_group_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_group auth_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);


--
-- Name: auth_permission auth_permission_content_type_id_codename_01ab375a_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);


--
-- Name: auth_permission auth_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);


--
-- Name: auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);


--
-- Name: auth_user auth_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);


--
-- Name: auth_user auth_user_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);


--
-- Name: blogApp_blogpost blogApp_blogpost_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."blogApp_blogpost"
    ADD CONSTRAINT "blogApp_blogpost_pkey" PRIMARY KEY (id);


--
-- Name: blogApp_blogpost blogApp_blogpost_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."blogApp_blogpost"
    ADD CONSTRAINT "blogApp_blogpost_slug_key" UNIQUE (slug);


--
-- Name: commonApp_userimage commonApp_userimage_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."commonApp_userimage"
    ADD CONSTRAINT "commonApp_userimage_pkey" PRIMARY KEY (id);


--
-- Name: dashboard_userdashboardmodule dashboard_userdashboardmodule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.dashboard_userdashboardmodule
    ADD CONSTRAINT dashboard_userdashboardmodule_pkey PRIMARY KEY (id);


--
-- Name: django_admin_log django_admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);


--
-- Name: django_content_type django_content_type_app_label_model_76bd3d3b_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);


--
-- Name: django_content_type django_content_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);


--
-- Name: django_migrations django_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);


--
-- Name: django_session django_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);


--
-- Name: jet_bookmark jet_bookmark_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jet_bookmark
    ADD CONSTRAINT jet_bookmark_pkey PRIMARY KEY (id);


--
-- Name: jet_pinnedapplication jet_pinnedapplication_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jet_pinnedapplication
    ADD CONSTRAINT jet_pinnedapplication_pkey PRIMARY KEY (id);


--
-- Name: projectsApp_category projectsApp_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_category"
    ADD CONSTRAINT "projectsApp_category_pkey" PRIMARY KEY (id);


--
-- Name: projectsApp_category projectsApp_category_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_category"
    ADD CONSTRAINT "projectsApp_category_slug_key" UNIQUE (slug);


--
-- Name: projectsApp_page projectsApp_page_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_page"
    ADD CONSTRAINT "projectsApp_page_pkey" PRIMARY KEY (id);


--
-- Name: projectsApp_project projectsApp_project_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_project"
    ADD CONSTRAINT "projectsApp_project_pkey" PRIMARY KEY (id);


--
-- Name: projectsApp_project projectsApp_project_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_project"
    ADD CONSTRAINT "projectsApp_project_slug_key" UNIQUE (slug);


--
-- Name: taggit_tag taggit_tag_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_tag
    ADD CONSTRAINT taggit_tag_name_key UNIQUE (name);


--
-- Name: taggit_tag taggit_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_tag
    ADD CONSTRAINT taggit_tag_pkey PRIMARY KEY (id);


--
-- Name: taggit_tag taggit_tag_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_tag
    ADD CONSTRAINT taggit_tag_slug_key UNIQUE (slug);


--
-- Name: taggit_taggeditem taggit_taggeditem_content_type_id_object_i_4bb97a8e_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_taggeditem
    ADD CONSTRAINT taggit_taggeditem_content_type_id_object_i_4bb97a8e_uniq UNIQUE (content_type_id, object_id, tag_id);


--
-- Name: taggit_taggeditem taggit_taggeditem_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_taggeditem
    ADD CONSTRAINT taggit_taggeditem_pkey PRIMARY KEY (id);


--
-- Name: commonApp_userimage uniqueForObject; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."commonApp_userimage"
    ADD CONSTRAINT "uniqueForObject" UNIQUE (identifier, content_type_id, object_id);


--
-- Name: projectsApp_page uniqueForProject; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_page"
    ADD CONSTRAINT "uniqueForProject" UNIQUE (project_id, number);


--
-- Name: auth_group_name_a6ea08ec_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);


--
-- Name: auth_group_permissions_group_id_b120cbf9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);


--
-- Name: auth_group_permissions_permission_id_84c5c92e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);


--
-- Name: auth_permission_content_type_id_2f476e4b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);


--
-- Name: auth_user_groups_group_id_97559544; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);


--
-- Name: auth_user_groups_user_id_6a12ed8b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);


--
-- Name: auth_user_user_permissions_permission_id_1fbb5f2c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);


--
-- Name: auth_user_user_permissions_user_id_a95ead1b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);


--
-- Name: auth_user_username_6821ab7c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);


--
-- Name: blogApp_blogpost_author_id_78e9d092; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "blogApp_blogpost_author_id_78e9d092" ON public."blogApp_blogpost" USING btree (author_id);


--
-- Name: blogApp_blogpost_slug_aa7d3b65_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "blogApp_blogpost_slug_aa7d3b65_like" ON public."blogApp_blogpost" USING btree (slug varchar_pattern_ops);


--
-- Name: commonApp_userimage_content_type_id_9b1dbf80; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "commonApp_userimage_content_type_id_9b1dbf80" ON public."commonApp_userimage" USING btree (content_type_id);


--
-- Name: commonApp_userimage_identifier_0835029b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "commonApp_userimage_identifier_0835029b" ON public."commonApp_userimage" USING btree (identifier);


--
-- Name: commonApp_userimage_identifier_0835029b_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "commonApp_userimage_identifier_0835029b_like" ON public."commonApp_userimage" USING btree (identifier varchar_pattern_ops);


--
-- Name: django_admin_log_content_type_id_c4bce8eb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);


--
-- Name: django_admin_log_user_id_c564eba6; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);


--
-- Name: django_session_expire_date_a5c62663; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);


--
-- Name: django_session_session_key_c0390e0f_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);


--
-- Name: projectsApp_category_slug_ec698f01_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projectsApp_category_slug_ec698f01_like" ON public."projectsApp_category" USING btree (slug varchar_pattern_ops);


--
-- Name: projectsApp_page_project_id_1be4c230; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projectsApp_page_project_id_1be4c230" ON public."projectsApp_page" USING btree (project_id);


--
-- Name: projectsApp_project_author_id_e2aceccb; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projectsApp_project_author_id_e2aceccb" ON public."projectsApp_project" USING btree (author_id);


--
-- Name: projectsApp_project_category_id_e65fc31e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projectsApp_project_category_id_e65fc31e" ON public."projectsApp_project" USING btree (category_id);


--
-- Name: projectsApp_project_slug_4de412fe_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "projectsApp_project_slug_4de412fe_like" ON public."projectsApp_project" USING btree (slug varchar_pattern_ops);


--
-- Name: taggit_tag_name_58eb2ed9_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX taggit_tag_name_58eb2ed9_like ON public.taggit_tag USING btree (name varchar_pattern_ops);


--
-- Name: taggit_tag_slug_6be58b2c_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX taggit_tag_slug_6be58b2c_like ON public.taggit_tag USING btree (slug varchar_pattern_ops);


--
-- Name: taggit_taggeditem_content_type_id_9957a03c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX taggit_taggeditem_content_type_id_9957a03c ON public.taggit_taggeditem USING btree (content_type_id);


--
-- Name: taggit_taggeditem_content_type_id_object_id_196cc965_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX taggit_taggeditem_content_type_id_object_id_196cc965_idx ON public.taggit_taggeditem USING btree (content_type_id, object_id);


--
-- Name: taggit_taggeditem_object_id_e2d7d1df; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX taggit_taggeditem_object_id_e2d7d1df ON public.taggit_taggeditem USING btree (object_id);


--
-- Name: taggit_taggeditem_tag_id_f4f5b767; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX taggit_taggeditem_tag_id_f4f5b767 ON public.taggit_taggeditem USING btree (tag_id);


--
-- Name: auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: blogApp_blogpost blogApp_blogpost_author_id_78e9d092_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."blogApp_blogpost"
    ADD CONSTRAINT "blogApp_blogpost_author_id_78e9d092_fk_auth_user_id" FOREIGN KEY (author_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: commonApp_userimage commonApp_userimage_content_type_id_9b1dbf80_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."commonApp_userimage"
    ADD CONSTRAINT "commonApp_userimage_content_type_id_9b1dbf80_fk_django_co" FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: projectsApp_page projectsApp_page_project_id_1be4c230_fk_projectsApp_project_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_page"
    ADD CONSTRAINT "projectsApp_page_project_id_1be4c230_fk_projectsApp_project_id" FOREIGN KEY (project_id) REFERENCES public."projectsApp_project"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: projectsApp_project projectsApp_project_author_id_e2aceccb_fk_auth_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_project"
    ADD CONSTRAINT "projectsApp_project_author_id_e2aceccb_fk_auth_user_id" FOREIGN KEY (author_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: projectsApp_project projectsApp_project_category_id_e65fc31e_fk_projectsA; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."projectsApp_project"
    ADD CONSTRAINT "projectsApp_project_category_id_e65fc31e_fk_projectsA" FOREIGN KEY (category_id) REFERENCES public."projectsApp_category"(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: taggit_taggeditem taggit_taggeditem_content_type_id_9957a03c_fk_django_co; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_taggeditem
    ADD CONSTRAINT taggit_taggeditem_content_type_id_9957a03c_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: taggit_taggeditem taggit_taggeditem_tag_id_f4f5b767_fk_taggit_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taggit_taggeditem
    ADD CONSTRAINT taggit_taggeditem_tag_id_f4f5b767_fk_taggit_tag_id FOREIGN KEY (tag_id) REFERENCES public.taggit_tag(id) DEFERRABLE INITIALLY DEFERRED;


--
-- PostgreSQL database dump complete
--

